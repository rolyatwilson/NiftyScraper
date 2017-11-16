module NiftyScrapper
  class Request
    class << self
      def get(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = url.start_with?('https')
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)
        raise 'Request failed' unless response.code == '200'
        response.body
      end
    end
  end
end
