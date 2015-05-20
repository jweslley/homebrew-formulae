require "language/go"

class Localdns < Formula
  homepage "https://github.com/jweslley/localdns"
  url "https://github.com/jweslley/localdns/archive/v0.1.0.tar.gz"
  sha1 "cb9e59e4b468caec2f78c785875724e0c9b39f5b"

  head "https://github.com/jweslley/localdns"

  depends_on "go" => :build

  go_resource "github.com/miekg/dns" do
    url "https://github.com/miekg/dns.git",
        :revision => "bb1103f648f811d2018d4bedcb2d4b2bce34a0f1"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/jweslley/"
    ln_sf buildpath, buildpath/"src/github.com/jweslley/localdns"
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build"
    bin.install "localdns"

    mv "ext/darwin/resolver", "/etc/resolver/dev"
  end

  test do
    system bin/"localdns", "-v"
  end

  plist_options :manual => "localdns"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
        <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{bin}/localdns</string>
        <string>-tld</string>
        <string>dev</string>
        <string>-port</string>
        <string>5353</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </plist>
    EOS
  end
end
