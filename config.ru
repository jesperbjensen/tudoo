map "/" do
  run Rack::File.new("/index.html")
end

run Rack::Directory.new("/app")
