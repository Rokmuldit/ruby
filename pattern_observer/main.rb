module Subject
    def initialize
        @observers = []
    end

    def attach(observer)
        @observers << observer unless @observers.include?(observer)
    end

    def detach(observer)
        @observers.delete(observer)
    end

    def notify(event_data = nil)
        @observers.each { |observer| observer.update(self, event_data) }
    end
end

class StockTicker
    include Subject
    attr_reader :symbol, :price

    def initialize(symbol, price)
        super()
        @symbol = symbol
        @price = price
    end

    def price=(new_price)
        old_price = @price
        @price = new_price
        notify({ old_price: old_price, new_price: new_price }) if old_price != new_price
    end
end

class TradingBot
    def update(ticker, data)
        puts "[Бот] #{ticker.symbol} змінив ціну: #{data[:old_price]} -> #{data[:new_price]}"
        puts "[Бот] Купуємо!" if data[:new_price] < 100
    end
end

class LoggerObserver
    def update(ticker, data)
        puts "[Лог] Зафіксовано зміну #{ticker.symbol} о #{Time.now}"
    end
end

apple_stock = StockTicker.new('AAPL', 150)

bot = TradingBot.new
logger = LoggerObserver.new

# Підписуємо спостерігачів
apple_stock.attach(bot)
apple_stock.attach(logger)

# Автоматично спрацьовують обидва спостерігачі
apple_stock.price = 95

# Відписуємо логер
apple_stock.detach(logger)

# Спрацює лише бот
apple_stock.price = 110

require 'observer'

class Order
    include Observable
    attr_reader :id, :status

    def initialize(id)
        @id = id
        @status = :pending
    end

    def update_status(new_status)
        return if @status == new_status

        @status = new_status
        changed # Обов'язково позначаємо, що стан змінився
        notify_observers(self) # Передаємо посилання на себе (Pull-модель)
    end
end

class EmailNotifier
    def update(order)
        puts "Email: Ваше замовлення #{order.id} тепер у статусі '#{order.status}'"
    end
end

order = Order.new(42)
order.add_observer(EmailNotifier.new)
order.update_status(:shipped)
