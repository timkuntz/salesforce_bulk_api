module SalesforceBulkApi

  class Connection

    @@XML_HEADER = '<?xml version="1.0" encoding="utf-8" ?>'
    @@API_VERSION = nil
    @@LOGIN_HOST = 'login.salesforce.com'
    @@INSTANCE_HOST = nil # Gets set in login()

    def initialize(api_version,client)
      @client=client
      @session_id = nil
      @server_url = nil
      @instance = nil
      @@API_VERSION = api_version
      @@LOGIN_PATH = "/services/Soap/u/#{@@API_VERSION}"
      @@PATH_PREFIX = "/services/async/#{@@API_VERSION}/"

      login()
    end

    #private

    def login()
      @session_id=@client.oauth_token
      @server_url=@client.instance_url
      @instance = parse_instance()
      puts @instance
      @@INSTANCE_HOST = "#{@instance}.salesforce.com"
      puts @@INSTANCE_HOST
    end

    def post_xml(host, path, xml, headers)
      host = host || @@INSTANCE_HOST
      if host != @@LOGIN_HOST # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
        path = "#{@@PATH_PREFIX}#{path}"
      end
      https(host).post(path, xml, headers).body
    end

    def get_request(host, path, headers, io = nil)
      host = host || @@INSTANCE_HOST
      path = "#{@@PATH_PREFIX}#{path}"
      if host != @@LOGIN_HOST # Not login, need to add session id to header
        headers['X-SFDC-Session'] = @session_id;
      end
      if io
        https(host).get(path, headers) {|chunk| io.write chunk}
      else
        https(host).get(path, headers).body
      end
    end

    def https(host)
      req = Net::HTTP.new(host, 443)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req
    end

    def parse_instance()
      @instance=@server_url.match(/https:\/\/(.*)\.salesforce\.com.*$/)[1]
    end

  end

end
