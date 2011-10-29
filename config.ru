map "/" do
  run Rack::File.new("/app/index.html")
end

run Rack::Directory.new("/app")
