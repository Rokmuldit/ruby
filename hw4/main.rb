require_relative 'game'

# Перехоплення Ctrl+C щоб програма не завершувалася аварійно
begin
    Battleship::Game.new.start
rescue Interrupt
    puts "\n\nГру перервано користувачем. До побачення!"
end