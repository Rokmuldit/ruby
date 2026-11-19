class Duck
    def quack; "..."; end
end

class Person
    def quack; "!!!"; end
end

def make_it_quack(entity)
    entity.quack
end

make_it_quack(Duck.new)
make_it_quack(Person.new)