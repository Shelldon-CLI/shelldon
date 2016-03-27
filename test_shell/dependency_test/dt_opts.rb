Shelldon.shell :test do
  opts do
    opt '--debug', '-d', :boolean
    opt '--help', '-h', :boolean
  end

  on_opt 'help' do
    puts "Here's some help!"
    exit 0
  end
end
