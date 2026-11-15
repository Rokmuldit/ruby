require_relative 'ship'
require_relative 'errors'

module Battleship
    # Клас ігрового поля 10x10
    class Board
        SIZE = 10
        FLEET_CONFIG = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1].freeze
        COLUMNS = ('A'..'J').to_a.freeze

        # Символи станів клітинок
        EMPTY = '.'
        SHIP  = 'S'
        HIT   = 'X'
        MISS  = '*'

        attr_reader :grid, :ships

        def initialize
            @grid = Array.new(SIZE) { Array.new(SIZE, EMPTY) }
            @ships = []
        end

        # Автоматичне випадкове розміщення всього флоту за правилами
        def place_ships_randomly
            FLEET_CONFIG.each do |size|
                placed = false
                until placed
                    orientation = [:horizontal, :vertical].sample
                    row = rand(0...SIZE)
                    col = rand(0...SIZE)

                    coords = generate_coordinates(row, col, size, orientation)
                    if valid_placement?(coords)
                        place_ship(size, coords)
                        placed = true
                    end
                end
            end
        end

        # Обробка пострілу по полю
        # Повертає символ результату: :miss, :hit або :sunk
        def receive_shot(row, col)
            cell = @grid[row][col]

            if cell == HIT || cell == MISS
                raise AlreadyShotError, 'Ви вже стріляли в цю клітинку! Спробуйте інші координати.'
            end

            if cell == SHIP
                @grid[row][col] = HIT
                ship = find_ship_at(row, col)
                ship.hit(row, col)
                ship.sunk? ? :sunk : :hit
            else
                @grid[row][col] = MISS
                :miss
            end
        end

        # Перевірка, чи всі кораблі на цьому полі знищені
        def all_ships_sunk?
            @ships.all?(&:sunk?)
        end

        # Формує масив рядків для відображення поля в консолі
        # Якщо hide_ships = true, живі кораблі ховаються за символом порожньої клітинки
        def render_lines(hide_ships: false)
            lines = []
            lines << "   #{COLUMNS.join(' ')}"
            @grid.each_with_index do |row, r_idx|
                display_row = row.map do |cell|
                    hide_ships && cell == SHIP ? EMPTY : cell
                end
                row_num = (r_idx + 1).to_s.rjust(2)
                lines << "#{row_num} #{display_row.join(' ')}"
            end
            lines
        end

        private

        # Генерує список координат для корабля заданого розміру та орієнтації
        def generate_coordinates(row, col, size, orientation)
            coords = []
            size.times do |i|
                r = orientation == :vertical ? row + i : row
                c = orientation == :horizontal ? col + i : col
                coords << [r, c]
            end
            coords
        end

        # Перевіряє, чи не виходить корабель за межі поля та чи не торкається інших кораблів
        def valid_placement?(coords)
            coords.all? do |r, c|
                in_bounds?(r, c) && neighbors_free?(r, c)
            end
        end

        def in_bounds?(row, col)
            row.between?(0, SIZE - 1) && col.between?(0, SIZE - 1)
        end

        # Перевіряє клітинку та всі 8 сусідніх клітинок навколо неї
        def neighbors_free?(row, col)
            (-1..1).each do |dr|
                (-1..1).each do |dc|
                    nr = row + dr
                    nc = col + dc
                    next unless in_bounds?(nr, nc)

                    return false if @grid[nr][nc] == SHIP
                end
            end
            true
        end

        # Записує корабель на поле та додає до списку флоту
        def place_ship(size, coords)
            coords.each { |r, c| @grid[r][c] = SHIP }
            @ships << Ship.new(size, coords)
        end

        # Знаходить об'єкт корабля за координатами палуби
        def find_ship_at(row, col)
            @ships.find { |ship| ship.coordinates.include?([row, col]) }
        end
    end
end