WORDS = ["Камінь", "Ножиці", "Папір"].freeze

def random_word
  WORDS.sample
end

def winner(user_choice, computer_choice)
  user = user_choice.to_s.strip.downcase
  computer = computer_choice.to_s.strip.downcase
  return 0 if user == computer

  user_beats = {
    "камінь" => "ножиці",
    "ножиці" => "папір",
    "папір" => "камінь"
  }

  user_beats[user] == computer ? 1 : 2
end

def play_game
  user_wins = 0
  computer_wins = 0
  draws = 0
  rounds = 0

  loop do
    puts "Камінь, ножиці, папір"
    user_choice = gets&.chomp.to_s.strip
    break if user_choice.empty?
    user_choice = user_choice.downcase.tr("?", "і")

    unless WORDS.any? { |word| word.downcase == user_choice.downcase }
      puts "Введіть камінь, ножиці або папір."
      puts "Значення яке ви ввели #{user_choice}"
      next
    end

    computer_choice = random_word
    puts "Вибір комп'ютера: #{computer_choice}"

    result = winner(user_choice, computer_choice)
    rounds += 1

    case result
    when 0
      draws += 1
      puts "Нічия!"
    when 1
      user_wins += 1
      puts "Ви перемогли!"
    when 2
      computer_wins += 1
      puts "Комп'ютер переміг!"
    end

    puts "Ваші перемоги: #{user_wins}, комп'ютер: #{computer_wins}, нічиї: #{draws}, раундів: #{rounds}"
    puts
  end
end

play_game
