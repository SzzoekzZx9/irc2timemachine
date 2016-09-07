require 'rubygems'
require 'cinch'
require 'osc-ruby'

  def sanitize_filename(filename)
    filename.gsub(/[^0-9A-z.\-]/, '_')
  end

  def start_machine (m)
    m.reply("Starting Recording")
    start = "oscsend localhost 7133 /start"
    system(start)
  end

  def stop_machine_custom (m)
    name = m.message.split(' ')[1]
    name = sanitize_filename(name)
    name = $save_location + "/" + name
    if File.exists?(name)
      m.reply("Already Exists, pls again")
    else
      m.reply("Stop Recording")
    end
    stop = "oscsend localhost 7133 /stop"
    system(stop)
    spam = Dir.glob($save_location + "/*").max_by {|f| File.mtime(f)}
    File.rename(spam,name)
    convert2mp3(name)
#delete here
    File.delete(name)
    spam = Dir.glob($save_location + "/*").max_by {|f| File.mtime(f)}
    m.reply("Converting to MP3")
    spam = spam.split('/').last
    m.reply($url + spam)
  end

  def stop_machine (m)
    m.reply("Stop Recording")
    stop = "oscsend localhost 7133 /stop"
    system(stop)
    spam = Dir.glob($save_location + "/*").max_by {|f| File.mtime(f)}
    convert2mp3(spam)
#delete here
    File.delete(spam)
    spam = Dir.glob($save_location + "/*").max_by {|f| File.mtime(f)}
    m.reply("Converting to MP3")
    spam = spam.split('/').last
    m.reply($url + spam)
  end

  def convert2mp3 (f)
    `ffmpeg -i #{f} -f mp3 #{f}.mp3`
  end

$save_location = ''
$url = ''
$irc_server = ''
$irc_channel = ''
$nickname = ''

IO.foreach("config") do |line|
  line.chomp!
  key, value = line.split(nil, 2)
  case key
  when /^([#;]|$)/; #Ignore line
  when "SAVELOCATION"; $save_location = value
  when "URL"; $url = value
  when "IRCSERVER"; $irc_server = value
  when "IRCCHANNEL"; $irc_channel = "#" + value
  when "NICKNAME"; $nickname = value
  when /^./; puts "#{key}: unknown key"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = $irc_server
    c.channels = [$irc_channel]
    c.nick = $nickname
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
