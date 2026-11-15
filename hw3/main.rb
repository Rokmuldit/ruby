class Sudoku4x4
    SIZE = 4
    BLOCK_SIZE = 2

    def initialize
        # Початкове поле
        @initial_board = [
            [1, 0, 0, 4],
            [0, 0, 1, 0],
            [0, 1, 0, 0],
            [4, 0, 0, 1]
        ]
        # Копія
        @board = @initial_board.map(&:dup)
    end

    def play
        puts "=== Вітаємо у грі Судоку 4x4! ==="
        puts "Для виходу введіть 'q' або 'exit' у будь-який момент.\n"

        loop do
            display_board

            if won?
                puts "\nВітаємо! Ви успішно розв'язали Судоку!"
                break
            end

            move = prompt_move
            break if move == :quit

            process_move(*move)
        end

        puts "Дякуємо за гру!"
    end

    private

    # Відображення поля в консолі
    def display_board
        puts "\n    1 2   3 4  (Стовпці)"
        puts "  +-----+-----+"
        @board.each_with_index do |row, r_idx|
            row_str = row.map { |val| val.zero? ? '.' : val }.join(' ')
            # Вставляємо вертикальний роздільник між блоками 2x2
            formatted_row = "#{row_str[0..2]} | #{row_str[4..6]}"
            puts "#{r_idx + 1} | #{formatted_row} |"
            puts "  +-----+-----+" if r_idx == 1
        end
        puts "  +-----+-----+"
    end

    # Обробка вводу користувача
    def prompt_move
        loop do
            print "\nВведіть рядок (1-4), стовпець (1-4) та число (1-4) через пробіл (або 0 для очищення): "
            input = gets&.chomp&.strip

            return :quit if input.nil? || %w[q exit вихід].include?(input.downcase)

            parts = input.split
            unless parts.size == 3 && parts.all? { |p| p.match?(/^\d+$/) }
                puts "[Помилка] Введіть рівно три числа через пробіл (наприклад: 1 2 3)."
                next
            end

            row, col, num = parts.map(&:to_i)

            unless row.between?(1, SIZE) && col.between?(1, SIZE) && num.between?(0, SIZE)
                puts "[Помилка] Рядок і стовпець мають бути від 1 до 4, а число — від 1 до 4 (або 0 для стирання)."
                next
            end

            # Для індексації масиву
            return [row - 1, col - 1, num]
        end
    end

    # Обробка ходу
    def process_move(row, col, num)
        if initial_cell?(row, col)
            puts "[Помилка] Ця клітинка є початковою! Її змінювати заборонено."
            return
        end

        if num.zero?
            @board[row][col] = 0
            puts "Клітинку очищено."
            return
        end

        if valid_move?(row, col, num)
            @board[row][col] = num
        end
    end

    # Перевірка, чи є число початковим
    def initial_cell?(row, col)
        !@initial_board[row][col].zero?
    end

    # Перевірка правильності ходу за правилами Судоку
    def valid_move?(row, col, num)
        if row_contains?(row, col, num)
            puts "[Помилка] Число #{num} вже є в цьому рядку!"
            return false
        end

        if col_contains?(row, col, num)
            puts "[Помилка] Число #{num} вже є в цьому стовпці!"
            return false
        end

        if block_contains?(row, col, num)
            puts "[Помилка] Число #{num} вже є в цьому блоці 2x2!"
            return false
        end

        true
    end

    def row_contains?(row, ignore_col, num)
        @board[row].each_with_index.any? { |val, c| c != ignore_col && val == num }
    end

    def col_contains?(ignore_row, col, num)
        @board.each_with_index.any? { |r, r_idx| r_idx != ignore_row && r[col] == num }
    end

    def block_contains?(row, col, num)
        start_row = (row / BLOCK_SIZE) * BLOCK_SIZE
        start_col = (col / BLOCK_SIZE) * BLOCK_SIZE

        (start_row...(start_row + BLOCK_SIZE)).each do |r|
            (start_col...(start_col + BLOCK_SIZE)).each do |c|
                next if r == row && c == col
                return true if @board[r][c] == num
            end
        end
        false
    end

    def won?
        @board.flatten.none?(&:zero?)
    end
end

Sudoku4x4.new.play