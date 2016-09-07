require 'rubygems'
require 'cinch'
require 'osc-ruby'
#require 'zaru'

  def sanitize_filename(filename)
    filename.gsub(/[^0-9A-z.\-]/, '_')
  end

#@client = OSC::Client.new( 'localhost', 7133 )
  def start_machine (m)
    m.reply("Starting Recording")
    start = "oscsend localhost 7133 /start"
    system(start)
#    @client.send(OSC::Message.new("/start", true))
  end

  def stop_machine_custom (m)
    name = m.message.split(' ')[1]
    name = sanitize_filename(name)
    name = "/mnt/data3/strim/tsbot/" + name
    if File.exists?(name)
      m.reply("Already Exists, pls again")
    else
      m.reply("Stop Recording")
    end
#    puts name
#    m.reply("Stop Recording")
    stop = "oscsend localhost 7133 /stop"
    system(stop)
    spam = Dir.glob("/mnt/data3/strim/tsbot/*").max_by {|f| File.mtime(f)}
    File.rename(spam,name)
    convert2mp3(name)
#delete here
    spam = Dir.glob("/mnt/data3/strim/tsbot/*").max_by {|f| File.mtime(f)}
    m.reply("Converting to MP3")
    spam = spam.split('/').last
    m.reply("http://themutedheart.com:3000/"+spam)
#    @client.send(OSC::Message.new("/stop", "mada"))
  end

  def stop_machine (m)
    m.reply("Stop Recording")
    stop = "oscsend localhost 7133 /stop"
    system(stop)
    spam = Dir.glob("/mnt/data3/strim/tsbot/*").max_by {|f| File.mtime(f)}
    convert2mp3(spam)
#delete here
    spam = Dir.glob("/mnt/data3/strim/tsbot/*").max_by {|f| File.mtime(f)}
    m.reply("Converting to MP3")
    spam = spam.split('/').last
    m.reply("http://themutedheart.com:3000/"+spam)
#    @client.send(OSC::Message.new("/stop", "mada"))
  end



  def convert2mp3 (f)
#    file = open(f)
#    puts f
    `ffmpeg -i #{f} -f mp3 #{f}.mp3`
#    return f
  end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "chat.freenode.net"
    c.channels = ["#vapelounge"]
    c.nick = "TeamspeakBot"
  end

  on :message do |m|
    if m.message.eql?("!start")
      start_machine (m)
    elsif m.message.start_with?("!stop ")
      stop_machine_custom (m)
    elsif m.message.eql?("!stop")
      stop_machine (m)
    end
  end
end

bot.start
