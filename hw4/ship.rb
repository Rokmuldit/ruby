module Battleship
    # Клас, що моделює окремий корабель на полі
    class Ship
        attr_reader :size, :coordinates

        def initialize(size, coordinates)
            @size = size
            @coordinates = coordinates # Масив координат виду [[row, col], ...]
            @hits = []                 # Клітинки корабля, у які вже влучили
        end

        # Реєструє влучання за координатами
        def hit(row, col)
            @hits << [row, col] unless @hits.include?([row, col])
        end

        # Перевіряє, чи знищено корабель повністю
        def sunk?
            @hits.size == @size
        end
    end
end