require_relative 'board'

module Battleship
    # Клас штучного інтелекту комп'ютера
    class ComputerAI
        def initialize
            # Перемішаний список усіх можливих координат (100 клітинок).
            @available_shots = (0...Board::SIZE).to_a.product((0...Board::SIZE).to_a).shuffle
        end

        # Вибирає наступну унікальну координату для пострілу
        def next_shot
            @available_shots.pop
        end
    end
end