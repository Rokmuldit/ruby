module Battleship
    # Базовий клас помилок для гри
    class GameError < StandardError; end

    # Помилка некоректного формату або діапазону введених координат
    class InvalidCoordinateError < GameError; end

    # Помилка при спробі вистрілити в клітинку, куди вже стріляли раніше
    class AlreadyShotError < GameError; end
end