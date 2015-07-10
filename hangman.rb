require 'sinatra'
require 'sinatra/reloader'

set :secret_number, 1 + rand(99)
@@bg_color =  "white"
@@guess_remain = 5

get '/' do
  cheat_condition = params["check"] == true && params["check"] != ""
  if params["guess"] && params["guess"] != "" && !params["check"]
    message = check_guess(params["guess"])
    @@guess_remain -= 1
    color = @@bg_color
  elsif !params["guess"] || params["guess"] == ""
    message = "Guess a number!"
  end

  got_answer = params["guess"].to_i == settings.secret_number
  if @@guess_remain == 0 && !got_answer
    settings.secret_number = 1 + rand(99)
    @@guess_remain = 5
    message = "You've lost your 5 guesses! A new number has been generated!"
  elsif got_answer
    settings.secret_number = 1 + rand(99)
    @@guess_remain = 5
    message = "You've guessed correctly! A new number has been generated!"
  end
  sn = settings.secret_number

  message += " CHEAT SOLUTION: #{settings.secret_number}" if params["cheat"]
  erb :index, :locals => {:message => message, :color => color, :sn => sn }
end

def check_guess(guess)
  msg = ""
  if guess.to_i > settings.secret_number
    msg = "Way too high!"
  elsif guess.to_i < settings.secret_number
    msg = "Way too low!"
  else
    msg = "The SECRET NUMBER is #{settings.secret_number}"
  end

  guess_distance = (settings.secret_number - guess.to_i).abs
  if guess_distance < 6 && guess_distance > 0
    @@bg_color = "FF5858"
  elsif guess_distance >= 6
    @@bg_color = "FF0000"
  else
    @@bg_color = "00FF00"
  end

  return msg
end
