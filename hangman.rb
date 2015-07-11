require 'sinatra'
require 'sinatra/reloader'

#initialization
set :prompt, "Set the difficulty. Enter an integer (between 2 and 28, "\
"inclusive) to set number of letters in target word:"
set :all_letters, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
set :all_difficulty, (2..28)

set :dictionary, File.open("enable.txt", "r") { |file| file.readlines }
set :bg_color, "FFFFFF"
set :difficulty, nil
set :word, ""
set :state, []
set :guess_remain, 5
set :proper_guess, false
set :correct_guess, false
set :bad_guess, Hash.new{0}
set :proper_difficulty, false
set :cheat_condition, false

get '/' do
  if params["guess"].eql? "restart"
    reset_everything
  end
  #setting local variables and etc.
  error_difficulty = ""
  error_guess = ""
  correct_msg = ""
  guess_msg = "Guesses Remaining: "
  message = ""

  #check for proper user difficulty inputs (must be integer in (2..28))
  if !settings.proper_difficulty
    if params["difficulty"] && params["difficulty"] != ""
      if settings.all_difficulty.include? (params["difficulty"].to_i)
        settings.difficulty = params["difficulty"].to_i
        find_word(params["difficulty"].to_i)
        settings.proper_difficulty = true
      else
        error_difficulty = "Error: Input not valid! Please enter an integer"\
        " between 2 and 28, inclusive!"
      end
    end
  end

  #check for proper user guess inputs (must be a single letter)
  not_empty_guess = params["guess"] && params["guess"] != ""
  settings.proper_guess = false
  if not_empty_guess
    if (settings.all_letters.include? params["guess"]) &&
      (params["guess"].length == 1)
      settings.proper_guess = true
    else
      settings.proper_guess = false
    end
  end

  #check for cheat mode
  settings.cheat_condition = params["cheat"].eql? "true"

  #Process Guesses
  if settings.guess_remain > 0 && !win_checker
    if settings.proper_guess
      check_guess(params["guess"])
      if settings.correct_guess
        correct_msg += "Your guess, #{params["guess"]}, was correct!"
        settings.bg_color = "00FF00"
      else
        correct_msg += "#{params["guess"]} is incorrect..."
        settings.bg_color = "FF0000"
      end
      color = settings.bg_color
      guess_msg += settings.guess_remain.to_s
    else
      error_guess = "Guess a single letter!"\
      " Your guess won't count otherwise!"
      guess_msg += settings.guess_remain.to_s
    end
  elsif settings.guess_remain <= 0
    guess_msg += "0"
    correct_msg = "You've lost your 5 guesses! The word was: #{settings.word}."\
    " Type \"restart\" and click the \"Guess Letter\" button to restart!"
  end
  if win_checker
    correct_msg = "You won!!!"\
    " Type \"restart\" and click the \"Guess Letter\" button to restart!"
  end

  #Rendering proper ERB templates
  message += " CHEAT SOLUTION: #{settings.word}" if settings.cheat_condition
  init_prompt = settings.prompt
  progress = display_progress
  bad_guess_msg = "Incorrect guesses: " + bad_guess_tally

  if settings.proper_difficulty
    erb :play, :locals => {
      :message => message,
      :color => color,
      :progress => progress,
      :error_guess => error_guess,
      :guess_msg => guess_msg,
      :correct_msg => correct_msg,
      :bad_guess_msg => bad_guess_msg
    }
  else
    erb :index, :locals => {
      :init_prompt => init_prompt,
      :error_difficulty => error_difficulty,
      :guess_msg => guess_msg
    }
  end
end

#finds random word of proper length at app level
def find_word(difficulty)
  #NEWLINE COUNTS AS A CHARACTER UGHHHH
  possible_words = settings.dictionary.select { |entry| entry.length-1 == difficulty}
  settings.word = possible_words[rand(possible_words.length)][0...-1]
  (0...settings.word.length).each do |index|
    settings.state[index] = false
  end
end

#displays the game progress
def display_progress
  disp = ""
  settings.state.each_with_index do |item, index|
    if item == false
      disp += "__ "
    else
      disp += "#{settings.word[index]} "
    end
  end
  return disp
end

#process the guess and update game info
def check_guess(guess)
  settings.correct_guess = false
  chars = settings.word.split("")
  chars.each_with_index do |c, index|
    if guess.eql? c
      settings.state[index] = true
      settings.correct_guess = true
    end
  end
  if !settings.correct_guess
    settings.guess_remain -= 1
    settings.bad_guess[guess] += 1
  end
end

#returns a string of all bad guesses
def bad_guess_tally
  return settings.bad_guess.keys.to_s
end

#returns true if answer is obtained, otherwise false
def win_checker
  settings.state.each do |element|
    return false if element == false
  end
  if settings.guess_remain >= 0
    return true
  end
  return false
end

#reset all game settings to initial settings
def reset_everything
  settings.bg_color = "FFFFFF"
  settings.difficulty = nil
  settings.word = ""
  settings.state.clear
  settings.guess_remain = 5
  settings.proper_guess = false
  settings.correct_guess = false
  settings.bad_guess.clear
  settings.proper_difficulty = false
  settings.restart = ""
end
