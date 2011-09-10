module VendorKit
  module CLI

    module Auth

      extend self

      def api_key
        VendorKit::Config.get(:"credentials.vendorage_api_key")
      end

      def api_key=(value)
        VendorKit::Config.set(:"credentials.vendorage_api_key", value)
      end

      def fetch_api_key
        puts "Please enter your vendorage.com login and password".yellow
        printf "Login: "
        username = STDIN.gets.chomp.strip
        printf "Password: "
        password = STDIN.gets.chomp.strip

        VendorKit::Config.set(:"credentials.vendorage_api_key", VendorKit::API.api_key(username, password))
      end

      def with_api_key(&block)
        fetch_api_key unless is_authenticated?
        yield api_key if api_key
      end

      def is_authenticated?
        !api_key.nil?
      end

    end

  end
end
