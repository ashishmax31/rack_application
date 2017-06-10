module Routes
  ROUTES = {
    "/hello" => "hello_controller.rb#hello",
    "/world" => "world_controller.rb#world",
    "/favicon.ico" => "application_controller.rb#favicon"
  }

  def self.match(env)
    controller_path = ROUTES[env["PATH_INFO"]]
    raise "Routes not set for the path: #{env["PATH_INFO"]}" if controller_path.nil?
    controller = controller_path.split("#").first
    c_method     = controller_path.split("#").last
    if File.file?("./app/controllers/#{controller}")  
      [controller, c_method] 
    else 
      raise "Controller not found for the path #{env["PATH_INFO"]}"
    end
  end

end