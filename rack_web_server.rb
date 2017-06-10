require 'socket'
require 'http/parser'


class RackWebServer

  def initialize(ip = "127.0.0.1", port)
    @server = TCPServer.new(ip, port)
  end

  def prefork
    4.times do
      fork do
        start
      end
    end
    waitall
  end

  def waitall
    Process.waitall
    puts "Killed all child Process"
  end


  def start
    loop do
      socket = @server.accept
      RequestHandler.new(socket).process_request
    end
  end

end




class RackWebServer
  module AppLoader
    def run(app)
      app
    end

    def load_app
      eval(File.read("application.rb"))
    end
  end
end


class RackWebServer
  class RequestHandler
    include RackWebServer::AppLoader
    HTTP_DEFINITIONS = {
          200 => 'OK',
          404 => 'Not Found'
        }

    def initialize(socket)
      @socket       = socket
      @app          = load_app
      @http_parser  = Http::Parser.new(self)
    end

    def process_request
      read_request_from_socket
    end

    def read_request_from_socket
      until @socket.closed? || @socket.eof?
        data            = @socket.readpartial(1024)
        @http_parser   << data
      end
    end

    # method `on_message_complete` is a callback method from Http::Parser library.Please refer the docs for more info.
    def on_message_complete
      send_response
      close_socket
      write_to_screen
    end

    def send_response
      status, headers, body = @app.call(rack_complient_env)
      @socket.write "HTTP/1.1 #{status} #{HTTP_DEFINITIONS[status]}\r\n"
      headers.each_pair { |key, value| @socket.write "#{key}: #{value}\r\n" }
      @socket.write "\r\n"
      body.each { |chunk| @socket.write chunk }
      body.close if body.respond_to?(:close)
    end

    def rack_complient_env
      env = {}
      env["PATH_INFO"] = @http_parser.request_url.to_s
      puts @http_parser.request_url
      env["REQUEST_METHOD"] = @http_parser.http_method
      env
    end

    def write_to_screen
      puts "#{@http_parser.http_method} #{@http_parser.request_url}"
      puts @http_parser.headers.inspect
      puts
    end

    def close_socket
      @socket.close
    end
  end
end

server = RackWebServer.new(3000)
puts "Puts starting server"
server.prefork
