def play_game
  secret = rand(1..100)
  attempts = 0

  puts "Я загадав число від 1 до 100."

  loop do
    print "Ваше припущення: "
    guess = gets.to_i
    attempts += 1

    if guess < secret
      puts "більше"
    elsif guess > secret
      puts "менше"
    else
      puts "вгадано"
      puts "Кількість спроб: #{attempts}"
      break
    end
  end
end

play_game
