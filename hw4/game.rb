require 'set'
require_relative 'board'
require_relative 'computer_ai'
require_relative 'errors'

module Battleship
    # Головний клас, що керує меню, статистикою та раундами гри
    class Game
        def initialize
            @stats = { wins: 0, losses: 0 }
        end

        # Запуск головного меню програми
        def start
            puts '========================================='
            puts '     ВІТАЄМО У ГРІ «МОРСЬКИЙ БІЙ»!       '
            puts '========================================='

            loop do
                display_menu
                choice = gets&.chomp&.strip

                case choice
                when '1'
                    play_round
                when '2'
                    display_rules
                when '3'
                    display_stats
                when '4', 'q', 'exit'
                    puts "\nДякуємо за гру! До зустрічі!"
                    break
                else
                    puts "\n[Помилка] Невідомий пункт меню. Оберіть число від 1 до 4."
                end
            end
        end

        private

        def display_menu
            puts "\n--- ГОЛОВНЕ МЕНЮ ---"
            puts "1. Почати нову гру"
            puts "2. Переглянути правила"
            puts "3. Статистика (Перемоги: #{@stats[:wins]} | Поразки: #{@stats[:losses]})"
            puts "4. Вихід з гри"
            print "Ваш вибір: "
        end

        def display_rules
            puts "\n--- ПРАВИЛА ГРИ «МОРСЬКИЙ БІЙ» ---"
            puts "1. Гра ведеться на полі 10x10 клітинок"
            puts "2. Флот кожного гравця складається з 10 кораблів:"
            puts "   - 1 корабель на 4 клітинки"
            puts "   - 2 кораблі на 3 клітинки"
            puts "   - 3 кораблі на 2 клітинки"
            puts "   - 4 кораблі на 1 клітинку"
            puts "3. Кораблі не можуть торкатися один одного навіть кутами."
            puts "4. Вводьте координати у форматі ЛітераЧисло (наприклад: A1, B5, J10)."
            puts "5. Позначення на полі:"
            puts "   'S' — ваш корабель"
            puts "   '.' — порожня або невідома клітинка"
            puts "   'X' — влучання"
            puts "   '*' — промах"
            puts "6. Перемагає той, хто першим знищить усі кораблі суперника!"
            puts "   Під час партії можна ввести 'menu', щоб здатися і вийти в меню."
        end

        def display_stats
            puts "\n--- СТАТИСТИКА ІГОР ---"
            puts "Перемог гравця:     #{@stats[:wins]}"
            puts "Поразок: #{@stats[:losses]}"
            puts "Всього зіграно:     #{@stats[:wins] + @stats[:losses]}"
        end

        # Запуск однієї ігрової партії
        def play_round
            @player_board = Board.new
            @computer_board = Board.new
            @player_board.place_ships_randomly
            @computer_board.place_ships_randomly
            @ai = ComputerAI.new

            puts "\nКораблі розставлено! Бій починається!"

            loop do
                display_boards

                # Хід гравця
                player_status = player_turn
                if player_status == :quit
                    puts "\nВи достроково покинули бій. Зараховано технічну поразку."
                    @stats[:losses] += 1
                    break
                end

                if @computer_board.all_ships_sunk?
                    display_boards
                    puts "\n========================================="
                    puts " ВІТАЄМО! Ви знищили весь ворожий флот! "
                    puts "========================================="
                    @stats[:wins] += 1
                    break
                end

                # Хід комп'ютера
                computer_turn

                if @player_board.all_ships_sunk?
                    display_boards
                    puts "\n========================================="
                    puts " ВИ ПРОГРАЛИ! Комп'ютер потопив ваш флот."
                    puts "========================================="
                    @stats[:losses] += 1
                    break
                end
            end
        end

        # Відображення двох полів поруч
        def display_boards
            puts "\n      ВАШЕ ПОЛЕ                   ПОЛЕ КОМП'ЮТЕРА"
            player_lines = @player_board.render_lines(hide_ships: false)
            comp_lines   = @computer_board.render_lines(hide_ships: true)

            player_lines.zip(comp_lines).each do |p_line, c_line|
                puts "#{p_line}         #{c_line}"
            end
            puts "\n[S] - Корабель | [X] - Влучання | [*] - Промах | [.] - Вода/Туман"
        end

        # Обробка ходу користувача з перехопленням помилок через begin / rescue
        def player_turn
            loop do
                print "\nВаш постріл (наприклад, A5 або 'menu' для виходу): "
                input = gets&.chomp&.strip

                return :quit if input.nil? || %w[menu q exit].include?(input.downcase)

                begin
                    row, col = parse_coordinates(input)
                    result = @computer_board.receive_shot(row, col)
                    report_shot('Ви', row, col, result)
                    break
                rescue GameError => e
                    # Перехоплюємо кастомні помилки
                    puts "[Помилка вводу] #{e.message}"
                end
            end
        end

        # Обробка ходу комп'ютера
        def computer_turn
            row, col = @ai.next_shot
            result = @player_board.receive_shot(row, col)
            report_shot("Комп'ютер", row, col, result)
        end

        # Перетворення текстової координати на індекси масиву [row, col]
        def parse_coordinates(input)
            if input.nil? || input.empty?
                raise InvalidCoordinateError, 'Координати не можуть бути порожніми!'
            end

            # Регулярний вираз: перша літера A-J, далі число від 1 до 10
            match = input.upcase.match(/\A([A-J])(10|[1-9])\z/)
            unless match
                raise InvalidCoordinateError, "Неправильний формат '#{input}'. Введіть літеру (A-J) та число (1-10) без пробілів, наприклад: B4 або J10."
            end

            col_char = match[1]
            row_num  = match[2].to_i

            row = row_num - 1
            col = Board::COLUMNS.index(col_char)

            [row, col]
        end

        # Виведення результату пострілу в консоль
        def report_shot(shooter, row, col, result)
            coord_str = "#{Board::COLUMNS[col]}#{row + 1}"
            action_word = shooter == 'Ви' ? 'вистрілили' : 'вистрілив'

            case result
            when :miss
                puts "-> #{shooter} #{action_word} у #{coord_str}: ПРОМАХ!"
            when :hit
                puts "-> #{shooter} #{action_word} у #{coord_str}: ВЛУЧАННЯ!"
            when :sunk
                puts "-> #{shooter} #{action_word} у #{coord_str}: КОРАБЕЛЬ ЗНИЩЕНО!"
            end
        end
    end
end