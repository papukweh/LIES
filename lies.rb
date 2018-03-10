class Card

	attr_reader :tipo, :valor;

	def initialize(tipo,valor)
		@tipo = tipo
		@valor = valor
	end

end

def printdeck(deck)
	deck.each {|x| print "#{ x.tipo == 1 ? "[#{x.tipo},#{x.valor}]" : "[#{x.tipo}]" } "}
	puts ""
end

deck = []

32.times 	{ deck << Card.new(0,0) }
4.times		{ deck << Card.new(2,0) }
2.times		{ deck << Card.new(5,0) }

deck << Card.new(1,[1,2,3])
deck << Card.new(1,[1,2,4])

deck << Card.new(1,[3,4,1])
deck << Card.new(1,[3,4,2])

deck << Card.new(1,[5,6,7])
deck << Card.new(1,[5,6,8])

deck << Card.new(1,[7,8,5])
deck << Card.new(1,[7,8,6])

deck << Card.new(1,[9,10,11])
deck << Card.new(1,[9,10,12])

deck << Card.new(1,[11,12,9])
deck << Card.new(1,[11,12,10])

deck.shuffle!

printdeck(deck)

swapped = 1

deck.each do |x|

	if(x.tipo==1)
		x, deck[49] = deck[49], x
		if(swapped%2.0!=0)
			swapped *= 2
		end
	end

	if(x.tipo==2)
		x, deck[48] = deck[48], x
		if(swapped%3.0!=0)
			swapped *= 3
		end
	end

	if(swapped%6.0==0)
		break
	end

end

printdeck(deck)