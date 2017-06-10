class Application

  def self.load_all
    Dir["./app/controllers/*.rb"].each{|file| require file}
  end

end
