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

def printcard(x)
	return "[#{x.tipo},#{x.valor}]"
end

def createdeck()
	deck = []

	32.times 	{ deck << Card.new(0,0) } # pistas irrelevantes (tipo 0)
	2.times		{ deck << Card.new(5,0) } # remove ferimentos (tipo 5)

	# ferimentos (tipo 2)
	deck << Card.new(2,-1) # corte
	deck << Card.new(2,-2) # impacto
	deck << Card.new(2,-3) # quimico
	deck << Card.new(2,-4) # tiro

	# armas (tipo 1) e seus subgrupos
	deck << Card.new(1,[-1,1,2,3])
	deck << Card.new(1,[-1,1,2,4])

	deck << Card.new(1,[-1,3,4,1])
	deck << Card.new(1,[-2,3,4,2])

	deck << Card.new(1,[-2,5,6,7])
	deck << Card.new(1,[-2,5,6,8])

	deck << Card.new(1,[-3,7,8,5])
	deck << Card.new(1,[-3,7,8,6])

	deck << Card.new(1,[-3,9,10,11])
	deck << Card.new(1,[-4,9,10,12])

	deck << Card.new(1,[-4,11,12,9])
	deck << Card.new(1,[-4,11,12,10])

	# deck embaralhado, config inicial do jogo
	deck.shuffle!
	#printdeck(deck)
	return deck
end

def monokuma(deck)
	swapped = 1

	# substitui as 2 ultimas cartas do deck por
	# uma arma e um ferimento (monokuma file) 
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

	#printdeck(deck)
	#puts "++++++++++++++++++++++++++++++++++++++++++++++++"
	#puts "Monokuma file: #{printcard(deck[48])}, #{printcard(deck[49])}"
	#puts "++++++++++++++++++++++++++++++++++++++++++++++++"
	return deck[48], deck[49]
end

def playround(nplayers, casos)
	# build the players vector
	players = []
	12.times {|x| players << x+1}

	# ordem de mortes e classes nao otulizadas
	players.shuffle!
	until players.length == nplayers do 
		players = players[0...-1]
	end

	round = 1

	until round == nplayers do
		deck = createdeck()
		deck.shuffle!
		monokuma = monokuma(deck)

		players.each do |x|
			armas = 0
			mao = []
			if x == -1
				2.times {  mao << deck[0]; deck = deck[1..49] }
			else
				5.times { mao << deck[0]; deck = deck[1..49] }
				screwed = 0
				ferimentos = 0
				mao.each do |y|
					if y.tipo == 1
						armas += 1
						y.valor[1..3].each do |z|
							if players.include? z
								if z!= x
									screwed+=1
								end
							end
						end
					elsif y.tipo == 2
						ferimentos += 1
					end
				end

				# nenhuma arma util
				if screwed == 0
					if armas == 0
						#puts "oh no, player #{x} has no weapons cards on round #{round}"
						casos[0] += 1
					else
						#puts "oh no, player #{x} has no useful weapon cards on round #{round}"
						casos[1] += 1
					end
					#printdeck(mao)
				end

				#nenhum ferimento
				if ferimentos == 0
					casos[2] +=1
				end
			end
		end

		# remove um jogador e incrementa o round
		players[-round] = -1
		round +=1
	end

	#puts "player #{players[0]} wins the game!"
end


# casos[0] = no armas
# casos[1] = no armas uteis
# jogadores[2] = no ferimentos
casos = [0.0,0.0,0.0]
jogos = 10000

jogos.times { playround(4, casos) }

puts "jogadores vivos sem armas: #{casos[0]} -> #{casos[0]/jogos} por jogo em média"
puts "jogadores vivos sem armas uteis: #{casos[1]} -> #{casos[1]/jogos} por jogo em média"
puts "jogadores vivos sem ferimentos: #{casos[2]} -> #{casos[2]/jogos} por jogo em média"