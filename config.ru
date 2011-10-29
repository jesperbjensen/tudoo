map "/" do
  run Rack::File.new("/")
end