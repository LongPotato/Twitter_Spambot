require 'jumpstart_auth'
require 'bitly'
require 'klout'

Bitly.use_api_version_3
Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'


class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message is too long"
    end
  end

  def run
    command = ""
    while command != "q"
      printf "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
         when 'q' then puts "Goodbye!"
         when 't' then tweet(parts[1..-1].join(" "))
         when 'dm' then dm(parts[1], parts[2..-1].join(" "))
         when 'spam' then spam_my_followers(parts[1..-1].join(" "))
         when 'elt' then everyone_last_tweet
         when 's' then shorten(parts[1..-1].join(" "))
         when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
         when 'klout' then klout_score

         else
           puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def dm(target, message)
  	screen_names = followers_list
    puts "Trying to send #{target} this direct message:"
    puts message
    if screen_names.include? target
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can only send message to people who folow you"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end

  def everyone_last_tweet
    friends = @client.followers.collect { |follower| @client.user(follower) }
    friends = friends.sort_by { |friend| friend.screen_name.downcase }
    friends.each do |friend|
      timestamp = friend.status.created_at
      puts "#{friend.screen_name} said this at #{timestamp.strftime("%A, %b %d")}: "
      puts friend.status.text
      puts
    end
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    bitly.shorten(original_url).short_url
  end

  def klout_score
    friends = followers_list
    friends.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      puts "#{friend} score: #{user.score.score}"
      puts
    end
  end


end

blogger = MicroBlogger.new
blogger.run




