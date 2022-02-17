class Haproxy < Formula
    desc "Reliable, high performance TCP/HTTP load balancer"
    homepage "https://www.haproxy.org/"
    url "https://www.haproxy.org/download/2.5/src/haproxy-2.5.2.tar.gz"
    sha256 "2de3424fd7452be1c1c13d5e0994061285055c57046b1cb3c220d67611d0da7e"
    depends_on "openssl@1.1"
    depends_on "pcre"
    depends_on "lua"
    
    uses_from_macos "zlib"

    def install
      lua = Formula["lua"]
      args = %W[
        TARGET=osx
        USE_PCRE2=1
        USE_PCRE2_JIT=1
        USE_OPENSSL=1
        USE_ZLIB=1
        ADDLIB=-lcrypto
        USE_LUA=1
        LUA_LIB=#{lua.opt_lib}
        LUA_INC=#{lua.opt_include}/lua
        LUA_LD_FLAGS=-L#{lua.opt_lib}
      ]

      # We build generic since the Makefile.osx doesn't appear to work
      system "make", *args
      man1.install "doc/haproxy.1"
      bin.install "haproxy"
    end

    service do
      run [opt_bin/"haproxy", "-f", etc/"haproxy.cfg"]
      keep_alive true
      log_path var/"log/haproxy.log"
      error_log_path var/"log/haproxy.log"
    end

    test do
      system bin/"haproxy", "-v"
    end
end
