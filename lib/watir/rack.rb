require "uri"
require "net/http"
require "rack"
require "watir"

require File.expand_path("rack/browser.rb", File.dirname(__FILE__))
require File.expand_path("rack/middleware.rb", File.dirname(__FILE__))

module Watir
  class Rack
    class << self
      private :new
      attr_accessor :test_app
      attr_reader :port, :middleware
      attr_writer :server
      attr_writer :port

      # Start the Rack
      # Will be called automatically by {Watir::Browser#initialize}.
      #
      # @param [Integer] port port for the Rack
      def boot(port: nil)
        unless running?
          @middleware = Middleware.new(app)
          @port = port || find_available_port

          @server_thread = Thread.new do
            server.call @middleware, @port
          end

          Timeout.timeout(boot_timeout) { @server_thread.join(0.1) until running? }
        end
      rescue Timeout::Error
        raise Timeout::Error, "Rack Rack application timed out during boot"
      end

      # Host for Rack app under test. Default is {.local_host}.
      #
      # @return [String] Host for Rack app under test.
      def host
        @host || local_host
      end

      # Set host for Rack app. Will be used by {Browser#goto} method.
      #
      # @param [String] host host to use when using {Browser#goto}.
      def host=(host)
        @host = host
      end

      # Local host for Rack app under test.
      #
      # @return [String] Local host with the value of "127.0.0.1".
      def local_host
        "127.0.0.1"
      end

      # Error rescued by the middleware.
      #
      # @return [Exception or NilClass]
      def error
        @middleware.error
      end

      # Returns true if there are pending requests to server.
      #
      # @return [Boolean]
      def pending_requests?
        @middleware.pending_requests?
      end

      # Set error rescued by the middleware.
      #
      # @param value
      def error=(value)
        @middleware.error = value
      end

      # Check if Rack app under test is running.
      #
      # @return [Boolean] true when Rack app under test is running, false otherwise.
      def running?
        return false if @server_thread && @server_thread.join(0)

        res = Net::HTTP.start(local_host, @port) { |http| http.get('/__identify__') }

        if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
          return res.body == @app.object_id.to_s
        end
      rescue Errno::ECONNREFUSED, Errno::EBADF
        return false
      end

      # Rack app under test.
      #
      # @return [Object] Rack Rack app.
      def app
        test_app = self.test_app

        @app ||= ::Rack::Builder.new do
          map "/" do
            run test_app
          end
        end.to_app
      end

      private

      def boot_timeout
        60
      end

      def find_available_port
        server = TCPServer.new(local_host, 0)
        server.addr[1]
      ensure
        server.close if server
      end

      def server
        @server ||= lambda do |app, port|
          begin
            require 'rack/handler/thin'
            Thin::Logging.silent = true
            return ::Rack::Handler::Thin.run(app, :Port => port)
          rescue LoadError
          end

          begin
            require 'rack/handler/puma'
            return ::Rack::Handler::Puma.run(app, :Port => port, :Silent => true)
          rescue LoadError
          end

          require 'rack/handler/webrick'
          ::Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
        end
      end

    end
  end
end
