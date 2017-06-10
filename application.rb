require "./config/routes.rb"
require "./config/environment.rb"
class RackApp
  include Routes
  def call(env)
    begin
    controller_path, method = Routes::match(env)
    Application.load_all
    result = send(method)
    puts result
    [200, { 'Content-Type' => 'text/html' },result]
    rescue Exception => e
      error = []
      [200, { 'Content-Type' => 'text/html' }, error << e.to_s]
    end
  end
end

run RackApp.new
