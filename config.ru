path = File.dirname(__FILE__)

map "/" do
  run Rack::File.new("#{path}/index.html")
end
map "/public" do
  run Rack::Directory.new("#{path}/public")
end