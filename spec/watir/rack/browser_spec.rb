require "spec_helper"

describe Watir::Browser do
  before { allow(Watir::Rack).to receive_messages(ignore_exceptions?: true) }

  context "#initialize" do
    it "starts Rack before opening the browser" do
      expect(Watir::Rack).to receive(:boot)
      expect_any_instance_of(Watir::Browser).to receive(:_original_initialize).and_call_original

      Watir::Browser.new
    end
  end

  context "#goto" do
    before do
      allow(Watir::Rack).to receive_messages(host: "foo.com", port: 42, boot: nil)
    end

    let(:browser) { Watir::Browser.new }

    it "uses Rack for paths specified as an url" do
      expect(browser).to receive(:_original_goto).with("http://foo.com:42/foo/bar")
      browser.goto("/foo/bar")
    end

    it "does not alter url with http:// scheme" do
      expect(browser).to receive(:_original_goto).with("http://baz.org/lol")
      browser.goto("http://baz.org/lol")
    end

    it "does not alter url with https:// scheme" do
      expect(browser).to receive(:_original_goto).with("https://baz.org/lol")
      browser.goto("https://baz.org/lol")
    end

    it "does not alter about:urls" do
      expect(browser).to receive(:_original_goto).with("about:url")
      browser.goto("about:url")
    end

    it "does not alter data:urls" do
      expect(browser).to receive(:_original_goto).with("data:url")
      browser.goto("data:url")
    end

    it "alters the unknown urls" do
      expect(browser).to receive(:_original_goto).with("http://foo.com:42/xxx:yyy")
      browser.goto("http://foo.com:42/xxx:yyy")
    end
  end
end
