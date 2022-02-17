class Haproxy < Formula
    desc "Reliable, high performance TCP/HTTP load balancer"
    homepage "https://www.haproxy.org/"
    url "https://www.haproxy.org/download/2.5/src/haproxy-2.5.2.tar.gz"
    sha256 "2de3424fd7452be1c1c13d5e0994061285055c57046b1cb3c220d67611d0da7e"
    depends_on "openssl@1.1"
    depends_on "pcre"
    depends_on "lua"

    def install
      lua = Formula["lua"]
      args = %W[
        TARGET=osx
        USE_KQUEUE=1
        USE_POLL=1
        USE_PCRE=1
        USE_OPENSSL=1
        USE_THREAD=1
        USE_ZLIB=1
        ADDLIB=-lcrypto
        USE_LUA=1
        LUA_LIB=#{lua.opt_lib}
        LUA_INC=#{lua.opt_include}/lua
        LUA_LD_FLAGS=-L#{lua.opt_lib}
      ]

      # We build generic since the Makefile.osx doesn't appear to work
      system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}", "LDFLAGS=#{ENV.ldflags}", *args
      man1.install "doc/haproxy.1"
      bin.install "haproxy"
    end

    plist_options :manual => "haproxy -f #{HOMEBREW_PREFIX}/etc/haproxy.cfg"

    def plist
      <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>Label</key>
            <string>#{plist_name}</string>
            <key>KeepAlive</key>
            <true/>
            <key>ProgramArguments</key>
            <array>
              <string>#{opt_bin}/haproxy</string>
              <string>-f</string>
              <string>#{etc}/haproxy.cfg</string>
            </array>
            <key>StandardErrorPath</key>
            <string>#{var}/log/haproxy.log</string>
            <key>StandardOutPath</key>
            <string>#{var}/log/haproxy.log</string>
          </dict>
        </plist>
      EOS
    end

    test do
      system bin/"haproxy", "-v"
    end
  end
