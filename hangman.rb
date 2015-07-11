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
set :word, {}
set :guess_remain, 5
set :proper_guess, false
set :proper_difficulty, false

get '/' do
  error_difficulty = ""
  error_guess = ""
  guess_msg = "Guesses Remaining: "
  message = ""

  #check user difficulty inputs (must be integer in (1..29))
  if !settings.proper_difficulty
    if params["difficulty"] && params["difficulty"] != ""
      if settings.all_difficulty.include? (params["difficulty"].to_i)
        settings.difficulty = params["difficulty"].to_i
        find_word(params["difficulty"].to_i)
        settings.proper_difficulty = true
      else
        error_difficulty = "Error: Input not valid! Please enter an integer"\
        " between 1 and 29, inclusive!"
      end
    end
  end

  #check user guess inputs (must be a single letter)
  not_empty_guess = params["guess"] && params["guess"] != ""
  if not_empty_guess
    if (settings.all_letters.include? params["guess"]) &&
      (params["guess"].length == 1)
      settings.proper_guess = true
    else
      settings.proper_guess = false
    end
  end

  #check for cheat mode
  cheat_condition = params["cheat"] == "true"


  #Process Guesses
  if settings.proper_guess
    message = check_guess(params["guess"])
    settings.guess_remain -= 1
    color = settings.bg_color
    guess_msg += settings.guess_remain.to_s
  else
    error_guess = "Guess a single letter!"\
    " Your guess won't count otherwise!"
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
  progress = display_progress
  if settings.proper_difficulty
    erb :play, :locals => {
      :message => message,
      :color => color,
      :progress => progress,
      :error_guess => error_guess,
      :guess_msg => guess_msg
    }
  else
    erb :index, :locals => {
      :init_prompt => init_prompt,
      :error_difficulty => error_difficulty,
      :guess_msg => guess_msg
    }
  end
end

#finds random word of proper length then configures word as hash at app level
def find_word(difficulty)
  possible_words = settings.dictionary.select { |entry| entry.length == difficulty}
  temp = possible_words[rand(possible_words.length)]
  templength = temp.length
  (0...templength).each do |x|
    settings.word[temp[x]] = false
  end
end

#displays the game progress
def display_progress
  disp = ""
  settings.word.each do |key, value|
    if value == false
      disp += "__ "
    else
      disp += "#{key} "
    end
  end
  return disp
end

#process the guess
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
