
def word_stats(text)
  words = text.split
  word_count = words.length
  words_unique_count = words.map(&:downcase).uniq.length
  longest_word = words.max_by(&:length)

  {
      word_count: word_count,
      words_unique_count: words_unique_count,
      longest_word: longest_word
  }
end

puts "Введіть текст:"

text = gets.chomp

result = word_stats(text)

puts "→ #{result[:word_count]} слів, найдовше: #{result[:longest_word]}, унікальних: #{result[:words_unique_count]}"
