.data
CHAR_POS:	.half 0,0			# x, y
OLD_CHAR_POS:	.half 0,0			# x, y

.text
SETUP:		la a0,map			# carrega o endereço do sprite 'map' em a0
		li a1,0				# x = 0
		li a2,0				# y = 0
		li a3,0				# frame = 0
		call PRINT			# imprime o sprite
		li a3,1				# frame = 1
		call PRINT			# imprime o sprite
		# esse setup serve pra desenhar o "mapa" nos dois frames antes do "jogo" começar

GAME_LOOP:	call KEY2			# chama o procedimento de entrada do teclado
		
		xori s0,s0,1			# inverte o valor frame atual (só o registrador)
		
		la t0,CHAR_POS			# carrega em t0 o endereço de CHAR_POS
		
		la a0,char			# carrega o endereço do sprite 'char' em a0
		lh a1,0(t0)			# carrega a posição x do personagem em a1
		lh a2,2(t0)			# carrega a posição y do personagem em a2
		mv a3,s0			# carrega o valor do frame em a3
		call PRINT			# imprime o sprite
		
		li t0,0xFF200604		# carrega em t0 o endereço de troca de frame
		sw s0,0(t0)			# mostra o sprite pronto para o usuário
		
		#####################################
		# Limpeza do "rastro" do personagem #
		#####################################
		la t0,OLD_CHAR_POS		# carrega em t0 o endereço de OLD_CHAR_POS
		
		la a0,tile			# carrega o endereço do sprite 'tile' em a0
		lh a1,0(t0)			# carrega a posição x antiga do personagem em a1
		lh a2,2(t0)			# carrega a posição y antiga do personagem em a2
		
		mv a3,s0			# carrega o frame atual (que está na tela em a3)
		xori a3,a3,1			# inverte a3 (0 vira 1, 1 vira 0)
		call PRINT			# imprime

		j GAME_LOOP			# continua o loop

KEY2:		li t1,0xFF200000		# carrega o endereço de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		# mascara o bit menos significativo
   		beq t0,zero,FIM   	   	# Se não há tecla pressionada então vai para FIM
  		lw t2,4(t1)  			# le o valor da tecla tecla
		
		li t0,'w'
		beq t2,t0,CHAR_CIMA		# se tecla pressionada for 'w', chama CHAR_CIMA
		
		li t0,'a'
		beq t2,t0,CHAR_ESQ		# se tecla pressionada for 'w', chama CHAR_CIMA
		
		li t0,'s'
		beq t2,t0,CHAR_BAIXO		# se tecla pressionada for 'w', chama CHAR_CIMA
		
		li t0,'d'
		beq t2,t0,CHAR_DIR		# se tecla pressionada for 'w', chama CHAR_CIMA
	
FIM:		ret				# retorna

CHAR_ESQ:	la t0,CHAR_POS			# carrega em t0 o endereço de CHAR_POS
		la t1,OLD_CHAR_POS		# carrega em t1 o endereço de OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)			# salva a posição atual do personagem em OLD_CHAR_POS
		
		lh t1,0(t0)			# carrega o x atual do personagem
		addi t1,t1,-16			# decrementa 16 pixeis
		sh t1,0(t0)			# salva
		ret

CHAR_DIR:	la t0,CHAR_POS			# carrega em t0 o endereço de CHAR_POS
		la t1,OLD_CHAR_POS		# carrega em t1 o endereço de OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)			# salva a posição atual do personagem em OLD_CHAR_POS
		
		la t0,CHAR_POS
		lh t1,0(t0)			# carrega o x atual do personagem
		addi t1,t1,16			# incrementa 16 pixeis
		sh t1,0(t0)			# salva
		ret

CHAR_CIMA:	la t0,CHAR_POS			# carrega em t0 o endereço de CHAR_POS
		la t1,OLD_CHAR_POS		# carrega em t1 o endereço de OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)			# salva a posição atual do personagem em OLD_CHAR_POS
		
		la t0,CHAR_POS
		lh t1,2(t0)			# carrega o y atual do personagem
		addi t1,t1,-16			# decrementa 16 pixeis
		sh t1,2(t0)			# salva
		ret

CHAR_BAIXO:	la t0,CHAR_POS			# carrega em t0 o endereço de CHAR_POS
		la t1,OLD_CHAR_POS		# carrega em t1 o endereço de OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)			# salva a posição atual do personagem em OLD_CHAR_POS
		
		la t0,CHAR_POS
		lh t1,2(t0)			# carrega o y atual do personagem
		addi t1,t1,16			# incrementa 16 pixeis
		sh t1,2(t0)			# salva
		ret
		

#################################################
#	a0 = endereço imagem			#
#	a1 = x					#
#	a2 = y					#
#	a3 = frame (0 ou 1)			#
#################################################
#	t0 = endereço do bitmap display		#
#	t1 = endereço da imagem			#
#	t2 = contador de linha			#
# 	t3 = contador de coluna			#
#	t4 = largura				#
#	t5 = altura				#
#################################################

PRINT:		li t0,0xFF0			# carrega 0xFF0 em t0
		add t0,t0,a3			# adiciona o frame ao FF0 (se o frame for 1 vira FF1, se for 0 fica FF0)
		slli t0,t0,20			# shift de 20 bits pra esquerda (0xFF0 vira 0xFF000000, 0xFF1 vira 0xFF100000)
		
		add t0,t0,a1			# adiciona x ao t0
		
		li t1,320			# t1 = 320
		mul t1,t1,a2			# t1 = 320 * y
		add t0,t0,t1			# adiciona t1 ao t0
		
		addi t1,a0,8			# t1 = a0 + 8
		
		mv t2,zero			# zera t2
		mv t3,zero			# zera t3
		
		lw t4,0(a0)			# carrega a largura em t4
		lw t5,4(a0)			# carrega a altura em t5
		
PRINT_LINHA:	lw t6,0(t1)			# carrega em t6 uma word (4 pixeis) da imagem
		sw t6,0(t0)			# imprime no bitmap a word (4 pixeis) da imagem
		
		addi t0,t0,4			# incrementa endereço do bitmap
		addi t1,t1,4			# incrementa endereço da imagem
		
		addi t3,t3,4			# incrementa contador de coluna
		blt t3,t4,PRINT_LINHA		# se contador da coluna < largura, continue imprimindo

		addi t0,t0,320			# t0 += 320
		sub t0,t0,t4			# t0 -= largura da imagem
		# ^ isso serve pra "pular" de linha no bitmap display
		
		mv t3,zero			# zera t3 (contador de coluna)
		addi t2,t2,1			# incrementa contador de linha
		bgt t5,t2,PRINT_LINHA		# se altura > contador de linha, continue imprimindo
		
		ret				# retorna

.data
.include "sprites/tile.s"
.include "sprites/map.s"
.include "sprites/char.s"
