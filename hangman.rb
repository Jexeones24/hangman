require 'sinatra'
require 'sinatra/reloader'

set :secret_number, 1 + rand(99)
@@bg_color =  "white"
@@guess_remain = 5
@@prompt = "Set the difficulty. Enter an integer (between 1 and 29, inclusive) to set number of letters in target word:"
@@difficulty = nil
dictionary = File.open("enable.txt", "r") { |file| file.readlines }

get '/' do
  @@difficulty = params["difficulty"] if !@@difficulty
  cheat_condition = params["check"] == true && params["check"] != ""
  if params["guess"] && params["guess"] != "" && !params["check"]
    message = check_guess(params["guess"])
    @@guess_remain -= 1
    color = @@bg_color
  elsif !params["guess"] || params["guess"] == "" || params["guess"].length > 1
    message = "Guess a letter!"
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
  init_prompt = @@prompt
  if @@difficulty && @@difficulty != ""
    erb :play, :locals => { :message => message, :color => color, :sn => sn }
  else
    erb :index, :locals => {:init_prompt => init_prompt}
  end
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
