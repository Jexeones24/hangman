require 'sinatra'
require 'sinatra/reloader'

#initialization
set :secret_number, 1 + rand(99)
set :prompt, "Set the difficulty. Enter an integer (between 1 and 29, "\
"inclusive) to set number of letters in target word:"
set :all_letters, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
set :all_difficulty, (1..29)

set :bg_color, "FFFFFF"
set :difficulty, nil
set :dictionary, File.open("enable.txt", "r") { |file| file.readlines }
set :guess_remain, 5

get '/' do
  error_difficulty = ""
  error_guess = ""
  guess_msg = "Guesses Remaining: "
  message = ""

  #Control and check game settings
  if settings.difficulty == nil
    if params["difficulty"] && params["difficulty"] != ""
      if settings.all_difficulty.include? (params["difficulty"].to_i)
        settings.difficulty = params["difficulty"].to_i
      else
        error_difficulty = "Error: Input not valid! Please enter an integer"\
        " between 1 and 29, inclusive!"
      end
    end
  end
  not_empty_guess = params["guess"] && params["guess"] != ""
  proper_guess = false
  if not_empty_guess
    if (settings.all_letters.include? params["guess"]) &&
      (params["guess"].length == 1)
      proper_guess = true
    else
      proper_guess = false
    end
  end
  cheat_condition = params["cheat"] == "true"


  #Process Guesses
  if proper_guess
    message = check_guess(params["guess"])
    settings.guess_remain -= 1
    color = settings.bg_color
    guess_msg += settings.guess_remain.to_s
  else
    error_guess = "Guess a single letter!"\
    " Your guess won't count otherwise!" if settings.guess_remain < 5
    guess_msg += settings.guess_remain.to_s
  end

  #Process game ending (win or lose)
  got_answer = params["guess"].to_i == settings.secret_number
  if settings.guess_remain == 0 && !got_answer
    settings.secret_number = 1 + rand(99)
    settings.guess_remain = 5
    message = "You've lost your 5 guesses! A new number has been generated!"
  elsif got_answer
    settings.secret_number = 1 + rand(99)
    settings.guess_remain = 5
    message = "You've guessed correctly! A new number has been generated!"
  end
  sn = settings.secret_number

  #Rendering proper ERB templates
  message += " CHEAT SOLUTION: #{settings.secret_number}" if cheat_condition
  init_prompt = settings.prompt
  if settings.difficulty && settings.difficulty != ""
    erb :play, :locals => { :message => message, :color => color, :sn => sn,
    :error_guess => error_guess, :guess_msg => guess_msg}
  else
    erb :index, :locals => { :init_prompt => init_prompt,
      :error_difficulty => error_difficulty,
      :guess_msg => guess_msg}
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
    settings.bg_color = "FF5858"
  elsif guess_distance >= 6
    settings.bg_color = "FF0000"
  else
    settings.bg_color = "00FF00"
  end

  return msg
end
