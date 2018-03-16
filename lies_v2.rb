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

	32.times 	{ deck << Card.new(0,0) } # pistas/locais irrelevantes (tipo 0)
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

def createdeckr()
	deck = []

	32.times 	{ deck << Card.new(0,0) } # pistas/locais irrelevantes (tipo 0)
	2.times		{ deck << Card.new(5,0) } # remove ferimentos (tipo 5)

	# ferimentos (tipo 2)
	deck << Card.new(2,-1) # corte
	deck << Card.new(2,-2) # impacto
	deck << Card.new(2,-3) # quimico
	deck << Card.new(2,-4) # tiro

	# armas (tipo 1) e seus subgrupos

	players = (1..12).to_a

	puts "Armas geradas aleatoriamente:"
	3.times do

		players.shuffle!

		for i in [0,3,6,9]
			deck << Card.new(1,players[i..(i+2)].push(-1).reverse)
			puts printcard(deck[-1])
		end

	end

	# deck embaralhado, config inicial do jogo
	#printdeck(deck)
	return deck
end

def monokuma(deck)
	swapped = 1

	# substitui as 2 ultimas cartas do deck por
	# uma arma e um ferimento (monokuma file) 
	deck.each do |x|

		if(x.tipo==1)
			x, deck[-1] = deck[-1], x
			if(swapped%2.0!=0)
				swapped *= 2
			end
		end

		if(x.tipo==2)
			x, deck[-2] = deck[-2], x
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
	#puts "Monokuma file: #{printcard(deck[deck.length-2])}, #{printcard(deck[deck.length-1])}"
	#puts "++++++++++++++++++++++++++++++++++++++++++++++++"
	return deck[deck.length-2], deck[deck.length-1]
end

def playround(splayers, nplayers, casos, decko)
	# build the players vector
	players = []
	chars   = Array.new(13,0)
	12.times {|x| players << x+1;}
	players.shuffle!

	# ordem de mortes e classes nao otulizadas

	i = 0
	until players.length == splayers do players.pop end	#corta o numero de jogadores até o numero inicial
	until players.length+i == nplayers					#transforma o resto em testemunhas
		players[i -= 1] = -1
	end

	deck = decko.clone
	deck.shuffle!

	monokuma = monokuma(deck)

	monokuma[1].valor[1..3].each {|x| chars[x] += 1}

	players.each do |x|
		armas = 0
		mao = []
		if x == -1
			2.times {  mao << deck.shift }
			mao.each do |y|
				if y.tipo == 1
					y.valor[1..3].each {|x| chars[x] += 1}
				end
			end
		else
			5.times { mao << deck.shift }
			screwed = 0
			ferimentos = 0
			mao.each do |y|
				if y.tipo == 1
					armas += 1
					y.valor[1..3].each do |z|
						if z !=x 
							chars[z] += 1
							if players.include? z
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
		#puts "this is player #{x}'s mao: "
		#printdeck(mao)
	end

	12.times do |x|
		if players.include? x
			if(chars[x]==0)
				casos[3] += 1
				#puts "hell yeah player #{x} can't be accused!"
			end
		end
	end

	#puts "player #{players[0]} wins the game!"
end


# casos[0] = no armas
# casos[1] = no armas uteis
# casos[2] = no ferimentos
# casos[3] = numero de não acusados
casos = [0.0,0.0,0.0,0.0]
splayers = ARGV[0].to_i
nplayers = splayers
jogos = ARGV[1].to_i

puts ""
deck = createdeckr

until nplayers == 1 do

	jogos.times { playround(splayers, nplayers, casos, deck) }

	puts ""
	puts "Testando com #{nplayers} jogadores, #{jogos} jogos:"
	puts "> jogadores vivos sem armas: #{casos[0]} -> #{casos[0]/jogos} por jogo em média"
	puts "> jogadores vivos sem armas uteis: #{casos[1]} -> #{casos[1]/jogos} por jogo em média"
	puts "> jogadores vivos sem ferimentos: #{casos[2]} -> #{casos[2]/jogos} por jogo em média"
	puts "> jogadores vivos que não acusaveis: #{casos[3]} -> #{casos[3]/jogos} por jogo em média"
	puts ""

	#printdeck(deck)

	nplayers -= 1;
	casos = [0.0,0.0,0.0,0.0]
end