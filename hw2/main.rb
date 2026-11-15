
# Функція для випадкової генерації пирога
def generate_cake(rows = 4, cols = 8)
    grid = Array.new(rows) { Array.new(cols, '.') }

    raisins_count = rand(2..9)

    all_positions = (0...rows).to_a.product((0...cols).to_a)
    raisin_positions = all_positions.sample(raisins_count)

    raisin_positions.each do |r, c|
        grid[r][c] = 'o'
    end

    grid.map(&:join).join("\n")
end

# Перетворює текстовий пиріг у двовимірний масив символів
def parse_cake(cake_str)
    cake_str.strip.lines.map { |line| line.strip.chars }
end

# Знаходить першу невідрізану клітинку (зверху вниз, зліва направо)
def find_first_empty_cell(grid, used)
    grid.each_index do |r|
        grid[0].each_index do |c|
            return [r, c] unless used[r][c]
        end
    end
    nil
end

# Перевіряє, чи не виходить шматок за межі та чи не перетинається з іншими
def can_cut?(used, start_r, start_c, height, width)
    max_r = used.length
    max_c = used[0].length
    return false if start_r + height > max_r || start_c + width > max_c

    (start_r...(start_r + height)).each do |r|
        (start_c...(start_c + width)).each do |c|
            return false if used[r][c]
        end
    end
    true
end

# Вирізає шматок пирога і повертає його у вигляді рядка
def extract_slice(grid, start_r, start_c, height, width)
    slice_lines = (start_r...(start_r + height)).map do |r|
        grid[r][start_c, width].join
    end
    slice_lines.join("\n")
end

# Позначає або знімає позначку з використаних клітинок пирога
def mark_used(used, start_r, start_c, height, width, state)
    (start_r...(start_r + height)).each do |r|
        (start_c...(start_c + width)).each do |c|
            used[r][c] = state
        end
    end
end

# Знаходить усі можливі розміри прямокутника заданої площі
# Сортує від найбільшої ширини до найменшої
def possible_dimensions(piece_area, max_height, max_width)
    dimensions = []
    max_width.downto(1) do |width|
        next unless (piece_area % width).zero?

        height = piece_area / width
        dimensions << [height, width] if height <= max_height
    end
    dimensions
end

# Рекурсивна функція пошуку правильного розрізу
def find_slices(grid, used, dimensions)
    empty_cell = find_first_empty_cell(grid, used)
    # Якщо вільних клітинок немає - пиріг успішно розрізано
    return [] if empty_cell.nil?

    start_r, start_c = empty_cell

    # Перебираємо можливі форми шматка (починаючи з найширших)
    dimensions.each do |height, width|
        next unless can_cut?(used, start_r, start_c, height, width)
        slice = extract_slice(grid, start_r, start_c, height, width)
        next unless slice.count('o') == 1
        mark_used(used, start_r, start_c, height, width, true)
        rest_slices = find_slices(grid, used, dimensions)
        return [slice] + rest_slices unless rest_slices.nil?

        # Якщо зайшли в глухий кут — скасовуємо розріз (відкат)
        mark_used(used, start_r, start_c, height, width, false)
    end

    nil
end

# Головна функція розрізання пирога
def cut_cake(cake_str)
    grid = parse_cake(cake_str)
    rows = grid.length
    cols = grid[0].length

    total_area = rows * cols
    raisins_count = cake_str.count('o')

    # Якщо площа не ділиться націло на кількість родзинок — рівні шматки неможливі
    return [] if raisins_count.zero? || (total_area % raisins_count) != 0

    piece_area = total_area / raisins_count
    dimensions = possible_dimensions(piece_area, rows, cols)
    used = Array.new(rows) { Array.new(cols, false) }

    find_slices(grid, used, dimensions) || []
end

# Допоміжна функція для гарного виводу результату
def print_solution(title, cake)
    puts "=== #{title} ==="
    puts "Початковий пиріг:\n#{cake}\n\n"

    result = cut_cake(cake)
    if result.empty?
        puts "Рішення не знайдено (неможливо поділити на рівні прямокутники)."
    else
        puts "Знайдено рішення (#{result.length} шматки):"
        puts "["
        result.each_with_index do |slice, idx|
            puts "#{slice} # шматок #{idx + 1}"
            puts "," if idx < result.length - 1
        end
        puts "]"
    end
    puts "\n"
end

cake1 = <<~CAKE
  .o......
  ......o.
  ....o...
  ..o.....
CAKE
print_solution("Приклад 1", cake1)

cake2 = <<~CAKE
  .o.o....
  ........
  ....o...
  ........
  .....o..
  ........
CAKE
print_solution("Приклад 2", cake2)

random_cake = generate_cake(4, 8)
print_solution("Приклад 3", random_cake)