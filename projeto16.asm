; *********************************************************************************
; * IST-UL
; * Alunos: Duarte São José - 103708
;           Alexandre Vudvud - 103363
; * PROJETO
; * Descrição: Este programa corresponde à primeira fase do
;              projeto "chuva de meteoros"
; *********************************************************************************


; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA    		 EQU 600AH           ; endereço do comando para definir a linha
DEFINE_COLUNA   	 	 EQU 600CH           ; endereço do comando para definir a coluna
DEFINE_PIXEL    	 	 EQU 6012H           ; endereço do comando para escrever um pixel
APAGA_AVISO     		 EQU 6040H           ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA	 		     EQU 6002H           ; endereço do comando para apagar todos os pixels já desenhados
APAGA_ECRA_ESP           EQU 6000H
SELECIONA_CENARIO_FUNDO  EQU 6042H           ; endereço do comando para selecionar uma imagem de fundo
DISPLAYS                 EQU 0A000H          ; endereço dos displays
SELECIONA_DISPLAY        EQU 6004H
ECRA_COMECO              EQU 1               ; ecra de comeco corresponde ao segundo ecra (ecra numero 1)
ECRA_PAUSA               EQU 2               ; ecra de pausa corresponde ao terceiro ecra (ecra numero 2)
ECRA_COLISAO             EQU 3               ; ecra de derrota por colisao corresponde ao quarto ecra (ecra numero 3)
ECRA_SEM_ENERGIA         EQU 4               ; ecra de derrota por falta de energia corresponde ao quinto ecra (ecra numero 4)
MIN_COLUNA		         EQU 0		         ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		         EQU 64              ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			         EQU 4FFFH		     ; atraso para limitar a velocidade de movimento do boneco


LARGURA_ROVER		     EQU	3			 ; largura do rover
ALTURA_ROVER             EQU    5            ; altura do rover

LARGURA_MET_MAU_5		 EQU	5			 ; largura do maior meteoro mau
ALTURA_MET_MAU_5         EQU    6            ; altura do maior meteoro mau

LARGURA_MET_BOM_5		 EQU	5			 ; largura do maior meteoro bom
ALTURA_MET_BOM_5         EQU    6            ; altura do maior meteoro bom

TOCA_SOM				 EQU 605AH           ; endereço do comando para tocar um som

AMARELO                  EQU 0FFE0H          ; cor do pixel: amarelo
VERMELHO                 EQU 0FF00H          ; cor do pixel: vermelho
PRETO                    EQU 0F000H          ; cor do pixel: preto
BRANCO                   EQU 0FFFFH          ; cor do pixel: branco
CINZENTO                 EQU 0FCCCH          ; cor do pixel: cinzento
VERDE                    EQU 0F5F0H          ; cor do pixel: verde
LARANJA                  EQU 0FF50H          ; cor do pixel: laranja
TOCA_MUSICA              EQU 605CH           ; reproduz musica/video em ciclo
TEC_LIN                  EQU 0C000H          ; endereco das linhas do teclado (periferico POUT-2)
TEC_COL                  EQU 0E000H          ; endereco das colunas do teclado (periferico PIN)
MASCARA_MENOR            EQU 0FH             ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
MASCARA_MAIOR            EQU 0FFH            ; para isolar os 8 bits de maior peso
N_METEOROS               EQU 4               ; numero de meteoros

LINHA_ROVER              EQU  27             ; linha do rover

; *********************************************************************************
; * Dados 
; *********************************************************************************

PLACE 1000H

; Reserva do espaço para as pilhas dos processos
	STACK 100H			; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:  ; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "controlo"
SP_inicial_controlo:	; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:	    ; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "rover", instância 0
SP_inicial_rover:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "energia"
SP_inicial_energia:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "missil"
SP_inicial_missil:		; este é o endereço com que o SP deste processo deve ser inicializado


; SP inicial de cada processo "meteoro"
	STACK 100H			; espaço reservado para a pilha do processo "meteoro", instância 0
SP_inicial_meteoro_0:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "meteoro", instância 1
SP_inicial_meteoro_1:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "meteoro", instância 2
SP_inicial_meteoro_2:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "meteoro", instância 3
SP_inicial_meteoro_3:		; este é o endereço com que o SP deste processo deve ser inicializado
							
tab:
	WORD rot_mover_meteoro		 ; rotina de atendimento da interrupção 0
    WORD rot_missil     ; rotina de atendimento da interrupção 1
    WORD rot_energia        ; rotina de atendimento da interrupção 2

meteoros_SP_tab:
	WORD	SP_inicial_meteoro_0
	WORD	SP_inicial_meteoro_1
	WORD	SP_inicial_meteoro_2
	WORD	SP_inicial_meteoro_3


DEF_METEORO_1:
    WORD 1, 1
    WORD CINZENTO

DEF_METEORO_2:
    WORD 2, 2
    WORD CINZENTO, CINZENTO
    WORD CINZENTO, CINZENTO

DEF_METEORO_MAU_3:
    WORD 3, 3
    WORD BRANCO, BRANCO, BRANCO
    WORD BRANCO, BRANCO, BRANCO
    WORD BRANCO, 0, BRANCO

DEF_METEORO_MAU_4:
    WORD 4, 4
    WORD BRANCO, BRANCO, BRANCO, BRANCO
    WORD BRANCO, PRETO, BRANCO, PRETO
    WORD BRANCO, BRANCO, BRANCO, BRANCO
    WORD BRANCO, 0, 0, BRANCO


DEF_METEORO_MAU_5:                          ; desenho do meteoro mau 5x5
    WORD LARGURA_MET_MAU_5, ALTURA_MET_MAU_5
    WORD          BRANCO,      BRANCO,      BRANCO,      BRANCO,      BRANCO
    WORD          BRANCO,      PRETO,       BRANCO,      PRETO,       BRANCO
    WORD          BRANCO,      BRANCO,      BRANCO,      BRANCO,      BRANCO
    WORD          BRANCO,      BRANCO,      PRETO,       BRANCO,      BRANCO
    WORD          BRANCO,      0,           BRANCO,      0,           BRANCO
    WORD          0,           0,           0,           0,           0
DEF_EXPLOSAO_BOM:                           ; desenho da explosao 5x5
    WORD LARGURA_MET_MAU_5, ALTURA_MET_MAU_5
    WORD          0,      0,      AMARELO,      0,      0
    WORD          0,      LARANJA,       0,      LARANJA,       0
    WORD          AMARELO,      0,      VERMELHO,      0,      AMARELO
    WORD          0,      LARANJA,      0,       LARANJA,      0
    WORD          0,      0,           AMARELO,      0,           0
    WORD          0,           0,           0,           0,           0

DEF_EXPLOSAO_MAU:                          ; desenho da explosao 5x5
    WORD LARGURA_MET_MAU_5, ALTURA_MET_MAU_5
    WORD          VERMELHO,      VERMELHO,      VERMELHO,      VERMELHO,      VERMELHO
    WORD          VERMELHO,      PRETO,       VERMELHO,      PRETO,       VERMELHO
    WORD          VERMELHO,      VERMELHO,      VERMELHO,      VERMELHO,      VERMELHO
    WORD          VERMELHO,      VERMELHO,      PRETO,       VERMELHO,      VERMELHO
    WORD          VERMELHO,      0,           VERMELHO,      0,           VERMELHO
    WORD          0,           0,           0,           0,           0

DEF_METEORO_BOM_3:
    WORD 3, 3
    WORD CINZENTO, 0, CINZENTO
    WORD LARANJA, LARANJA, LARANJA
    WORD PRETO, PRETO, PRETO

DEF_METEORO_BOM_4:
    WORD 4, 4
    WORD CINZENTO, 0, 0, CINZENTO
    WORD LARANJA, LARANJA, LARANJA, LARANJA
    WORD PRETO, PRETO, PRETO, PRETO
    WORD PRETO, PRETO, PRETO, PRETO

DEF_METEORO_BOM_5:  
    WORD LARGURA_MET_BOM_5, ALTURA_MET_BOM_5
    WORD 0, CINZENTO, 0, CINZENTO, 0
    WORD LARANJA, LARANJA, LARANJA, LARANJA, LARANJA
    WORD PRETO, PRETO, LARANJA, PRETO, PRETO
    WORD PRETO, PRETO, LARANJA, PRETO, PRETO
    WORD PRETO, PRETO, PRETO, PRETO, PRETO
    WORD 0, 0, 0, 0, 0

DEF_METEORO_BOM:
    WORD DEF_METEORO_1
    WORD DEF_METEORO_2
    WORD DEF_METEORO_BOM_3
    WORD DEF_METEORO_BOM_4
    WORD DEF_METEORO_BOM_5
    WORD DEF_EXPLOSAO_BOM

DEF_METEORO_MAU:
    WORD DEF_METEORO_1
    WORD DEF_METEORO_2
    WORD DEF_METEORO_MAU_3
    WORD DEF_METEORO_MAU_4
    WORD DEF_METEORO_MAU_5
    WORD DEF_EXPLOSAO_MAU

DEF_ROVER:                                   ; desenho do rover
    WORD LARGURA_ROVER, ALTURA_ROVER
    WORD           AMARELO,     AMARELO,      AMARELO
    WORD           PRETO,       PRETO,        PRETO
    WORD           PRETO,       PRETO,        PRETO
    WORD           0,           PRETO,        0
    WORD           0,           PRETO,        0
    WORD           0,           PRETO,        0

DEF_MISSIL:
    WORD 0
    WORD 0, 0
    WORD AMARELO

linha_meteoro:				 ; linha em que cada meteoro está (inicializada com a linha inicial)
	WORD 0
	WORD 0
	WORD 0
	WORD 0

coluna_meteoro:				 ; coluna em que cada meteoro está (inicializada com a coluna inicial)
	WORD 0
	WORD 0
	WORD 0
	WORD 0

bom_mau:                     ; 1 se o meteoro for bom, 0 se for mau
	WORD 0
	WORD 0
	WORD 0
	WORD 0

; estado_evolucao_meteoro:    ; fase de evolucao (1, 2, 3, 4 ou 5)
; 	WORD 1
; 	WORD 1
; 	WORD 1
; 	WORD 1

LINHA_METEORO:  WORD   -1                    ; linha inicial do meteoro
COLUNA_ROVER:   WORD   30                    ; coluna inicial do rover
VALOR_DISPLAY:  WORD   100H                  ; valor inicial dos displays
COLUNA_METEORO: WORD   12                    ; coluna do meteoro
COLISAO_BALA:   WORD   0                     ; flag de colisao meteoro-bala
COLIDIU_BOM:    WORD   0                     ; flag de colisao meteoro bom-rover
EM_START:       WORD   1                     ; flag que indica se estamos ou não no ecrã de start
GAME_OVER:      LOCK   0                     ; flag que indica se o jogo acabou e como acabou (1-energia, 2-colisao, 3-pausa, 4-termino voluntario do jogo)
MISSIL_ANDA:    LOCK   0

evento_int_meteoro: LOCK 0                   ; flag de movimento do meteoro 
DECRESCE_ENERGIA:   LOCK 0                   ; flag de decrescimento de energia


tecla_carregada:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou


; *********************************************************************************
; * Código
; *********************************************************************************

PLACE 0

; corpo principal do programa


inicializacoes:
    MOV SP, SP_inicial_prog_princ       ; inicializacao do Stack Pointer
    MOV BTE, tab        ; inicializa BTE (registo de Base da Tabela de Exceções)
    MOV [APAGA_AVISO], R1       ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV [APAGA_ECRA], R1        ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    EI0     ; permite interrupções 0
    EI1
    EI2
	EI      ; permite interrupções (geral)
    MOV R0, 3
    MOV [TOCA_MUSICA], R0

CALL controlo       ; inicia o processo de controlo
CALL desenha_rover      ; desenha o rover
CALL inicio_teclado         ; inicia o processo do teclado
CALL rover      ; inicia o processo do rover
CALL energia        ; inicia o processo da energia
CALL missil     ; inicia o processo do missil
MOV	R11, N_METEOROS	    ; número de meteoros a usar
loop_meteoros:
    SUB	R11, 1	        ; próximo meteoro
    CALL meteoro	    ; cria uma nova instância do processo meteoro (o valor de R10 distingue-as)
                        ; Cada processo fica com uma cópia independente dos registos
    CMP  R11, 0	        ; já criou as instâncias todas?
    JNZ	loop_meteoros       ; se não, continua




; **********************************************************************
; Processo
;
; Controlo - Processo responsavel por tratar das teclas de começar, 
;            suspender/continuar e terminar o jogo.
;
; **********************************************************************

PROCESS SP_inicial_controlo
    controlo:
    MOV R1, [EM_START]          ; coloca em R1 a variavel que permite saber se estamos ou nao no ecra de start
    CMP R1, 1           ; verifica se estamos ou nao no ecra de start
    JNZ ja_comecou      ; se nao, salta para o ciclo do jogo
        start:        ; ecra de start
            MOV R1, 30      ; coluna inicial do rover
            MOV [COLUNA_ROVER], R1      ; inicializa a coluna do rover
            MOV R1, 0
            MOV [EM_START], R1      ; altera a variavel nao voltar ao ciclo quando sair deste
            MOV R6, 8       ; linha que se quer verificar em R6
            MOV R4, 0CH
            MOV [APAGA_ECRA], R6        ; apaga todos os pixeis do ecra
            MOV R7, ECRA_COMECO 
            MOV [SELECIONA_CENARIO_FUNDO], R7       ; muda o background para o de start 
            ciclo_start:
                CALL teclado        ; verifica se ha alguma tecla primida na linha em R6
                CMP R0, 0       ; se nao há tecla primida
                JZ ciclo_start      ; volta ao inicio do ciclo
                CALL descobre_tecla   ; qual a tecla primida?
                CMP R8, R4      ; se for a tecla "C", 
                JZ inicializa_displays      ; comeca o jogo
                JMP ciclo_start     ; se nao, permanece no ciclo
        inicializa_displays:
            MOV R1, 100H
            MOV [VALOR_DISPLAY], R1     ; inicializa o valor dos displays 
            MOV [DISPLAYS], R1      ; inicializa os displays 
        ja_comecou:
            CALL desenha_rover      ; desenha o rover
            MOV R7, 0 
            MOV [SELECIONA_CENARIO_FUNDO], R7       ; muda o background para o background principal do jogo
            MOV R0, [GAME_OVER]         ; le o lock
            CMP R0, 0       ; verifica se a variavel game_over foi alterada
            JZ controlo         ; se nao, continua no jogo 
            CMP R0, 1
            JZ acabou_energia       ; se foi alterada para 1, o rover ficou sem energia
            CMP R0, 2
            JZ derrota_colisao      ; se foi alterada para 2, o rover foi destruido por colisao
            CMP R0, 3
            JZ pausa        ; se foi alterada para 3, o jogo foi colocado em pausa

        terminar_jogo:      ; termina o jogo
            MOV R1, linha_meteoro ; tabela da slinhas dos meteoros em R1
            MOV R2, 33
            MOV [R1], R2        ; altera a linha do meteoro para que este fique fora do ecra. Deste modo, quando o jogo for reiniciado, o meteoro sera tambem reiniciado
            ADD R1, 2       ; passa para a linha do meteoro seguinte
            MOV [R1], R2        ; altera a linha do meteoro para que este fique fora do ecra. Deste modo, quando o jogo for reiniciado, o meteoro sera tambem reiniciado
            ADD R1, 2       ; passa para a linha do meteoro seguinte
            MOV [R1], R2        ; altera a linha do meteoro para que este fique fora do ecra. Deste modo, quando o jogo for reiniciado, o meteoro sera tambem reiniciado
            ADD R1, 2       ; passa para a linha do meteoro seguinte
            MOV [R1], R2        ; altera a linha do meteoro para que este fique fora do ecra. Deste modo, quando o jogo for reiniciado, o meteoro sera tambem reiniciado
            MOV R1, 1
            MOV [EM_START], R1      ; altera a variavel EM_START para 1 para que o tilizador possa reiniciar o jogo
            JMP controlo        ; volta ao inicio do processo

        pausa:
            MOV R6, 0
            MOV [GAME_OVER], R6     ; game_over volta a 0 para que quando o programa saia deste ciclo saber que pode voltar ao jogo principal
            MOV R6, 8       ; linha que se quer verificar
            MOV R4, 0DH
            MOV R5, 0EH
            MOV [APAGA_ECRA], R6        ; apaga o ecra 
            MOV R7, ECRA_PAUSA
            MOV [SELECIONA_CENARIO_FUNDO], R7       ; seleciona o background de pausa
            CALL espera_nao_tecla   ; espera que nao haja nenhuma tecla primida
            ciclo_pausa:
                CALL teclado        ; ve se ha alguma tecla primida na linha em R6
                CALL descobre_tecla         ; descobre qual essa tecla (no caso de nao haver nenhuma nao tem problema, pois devolve C)
                CMP R8, R4      ; ve se a tecla D esta primida
                JZ sair_pausa       ; se sim, sai da pausa
                CMP R8, R5       ; ve se a tecla E esta primida
                JZ controlo     ; se sim, volta ao inicio do processo
                JMP ciclo_pausa     ; se nao, volta ao inicio do ciclo
                sair_pausa:
                    CALL espera_nao_tecla       ; espera que nao haja nenhuma tecla primida
                    JMP ja_comecou      ; sai da pausa

        derrota_colisao:
            CALL tocar_derrota
            MOV R6, 0
            MOV [GAME_OVER], R6     ; GAME_OVER volta a 0
            MOV R6, 8       ; seleciona a linha
            MOV R4, 0EH
            MOV [APAGA_ECRA], R6        ; apaga o ecra
            MOV R7, ECRA_COLISAO
            MOV [SELECIONA_CENARIO_FUNDO], R7       ; muda o background para o de colisao
            ciclo_derrota_colisao:
                CALL teclado        ; ve se ha alguma tecla primida na linha em R6
                CALL descobre_tecla     ; descobre qual essa tecla (no caso de nao haver nenhuma nao tem problema, pois devolve C)
                CMP R8, R4      ; ve se a tecla E esta primida
                JZ controlo     ; se sim, volta ao inicio do processo
                JMP ciclo_derrota_colisao       ; se nao, mantem-se no ciclo de colisao
        acabou_energia:
            CALL tocar_derrota
            MOV R6, 0
            MOV [GAME_OVER], R6     ; GAME_OVER volta a 0
            MOV R6, 8       ; seleciona a linha
            MOV R4, 0EH
            MOV [APAGA_ECRA], R6        ; apaga o ecra
            MOV R7, ECRA_SEM_ENERGIA
            MOV [SELECIONA_CENARIO_FUNDO], R7       ; muda o background para o de sem energia
            ciclo_acabou_energia:
                CALL teclado        ; ve se ha alguma tecla primida na linha em R6
                CALL descobre_tecla       ; descobre qual essa tecla (no caso de nao haver nenhuma nao tem problema, pois devolve C)
                CMP R8, R4       ; ve se a tecla E esta primida
                JZ controlo     ; se sim, volta ao inicio do processo
                JMP ciclo_acabou_energia


; **********************************************************************
; Processo
;
; inicio_teclado - Processo que deteta quando se carrega numa tecla
;		  do teclado e escreve o valor da tecla num LOCK.
;
; **********************************************************************
PROCESS SP_inicial_teclado
    inicio_teclado:
        ; inicializações
        MOV R4, TEC_LIN         ; endereço do periférico das linhas
        MOV R3, TEC_COL     ; endereço do periférico das colunas
        MOV R5, MASCARA_MENOR       ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
            
    espera_tecla:       ; neste ciclo espera-se até uma tecla ser premida
        YIELD
        MOV  R6, 16     ; linha a testar no teclado
        linha:
            SHR R6, 1       ; passa para a linha anterior
            JZ espera_tecla     ; espera, enquanto não houver tecla
            CALL teclado        ; leitura às teclas
            CMP	R0, 0       ; verifica se há alguma tecla primida
            JZ linha        ; se não houver, vai testar para a linha seguinte
        CALL descobre_tecla     ; se houver, vai descobrir qual a tecla primida, guardando-a em R8
        MOV [tecla_carregada], R8       ; altera a variavel lock "tecla_carregada" para a tecla primida
        verificar_se_houve_pausa:
            MOV R1, 0DH
            CMP R8, R1     ; verifica se a tecla D foi primida
            JNZ verificar_se_houve_terminar_jogo        ; se nao foi salta
            MOV R1, 3
            MOV [GAME_OVER], R1
            JMP ha_tecla
        verificar_se_houve_terminar_jogo:
            MOV R1, 0EH
            CMP R8, R1         ; verifica se a tecla E foi primida 
            JNZ ha_tecla        ; se nao, salta para ha_tecla
            MOV R1, 4
            MOV [GAME_OVER], R1     ; se a tecla E foi primida, coloca GAME_OVER a 4

    ha_tecla:       ; neste ciclo espera-se até uma tecla ser premida
        YIELD
        MOV  R6, 16     ; linha a testar no teclado
        linha_seg:
            SHR R6, 1       ; passa para a linha anterior
            JZ ha_tecla	        ; espera, enquanto não houver tecla
            CALL teclado        ; leitura às teclas
            CMP	R0, 0       ; verifica se há alguma tecla primida
            JNZ linha_seg       ; se não houver, vai testar para a linha seguinte
        JMP espera_tecla


; **********************************************************************
; Processo
;
; Rover - Processo responsavel por movimentar o rover.
;
; **********************************************************************
PROCESS SP_inicial_rover
    rover:
        MOV R0, [tecla_carregada]       ; le o lock da tecla carregada
        YIELD       ; pode sair do processo
        CMP R0, 0       ; verifica se a tecla primida foi 0
        JZ andar_esquerda       ; se sim, anda para a esquerda
        CMP R0, 2       ; verifica se a tecla primida foi 2
        JZ andar_direita        ; se sim, anda para a direita
        JMP rover         ; se nao, volta ao inicio do ciclo
        andar_esquerda:
            MOV R7, -1      ; R7 fica com o valor a adicionar à posição atual do rover
            MOV R11, ATRASO     ; R11 guarda o valor do atraso
            CALL ciclo_atraso       ; chama o ciclo de atraso para diminuir a velocidade de movimento do rover
            MOV R2, [COLUNA_ROVER]      ; coloca o valor da coluna atual do rover no R2
            CALL verifica       ; chama a função responsável por apagar os pixeis do rover
            JMP rover      ; volta ao inicio do ciclo

        andar_direita:
            MOV R7, 1       ; R7 fica com o valor a adicionar à posição atual do rover
            MOV R11, ATRASO     ; R11 guarda o valor do atraso
            CALL ciclo_atraso       ; chama o ciclo de atraso para diminuir a velocidade de movimento do rover
            MOV R2, [COLUNA_ROVER]      ; coloca o valor da coluna atual do rover no R2
            CALL verifica       ; chama a função responsável por apagar os pixeis do rover
            JMP rover       ; volta ao inicio do ciclo


; **********************************************************************
; Processo
;
; Energia - Processo responsavel por evoluir o valor da energia do rover.
;
; **********************************************************************
PROCESS SP_inicial_energia
    energia:
        MOV R3, [DECRESCE_ENERGIA]      ; lê o LOCK desta instância (bloqueia até a rotina de interrupção)
        CALL decrementa_5      ; decrece a energia em 5 unidades
        JMP energia       ; volta ao inicio do ciclo


; **********************************************************************
; Processo
;
; Missil - Processo responsavel por controlar o disparo e a 
;          evolução do míssil no espaço e alcance.
;
; **********************************************************************
PROCESS SP_inicial_missil
    missil:
        MOV R0, [tecla_carregada]
        YIELD
        CMP R0, 1       ; se a tecla "1" foi premida, é para disparar
        JNZ missil      ; se não, volta-se ao inicio
        CALL inicia_missil      ; disparar o missil
        CALL decrementa_5      ; decrementa a energia em 5 unidades
        move_missil:
        YIELD       ; pode sair do processo
        MOV R1, DEF_MISSIL      ; tabela do missil em R1
        MOV R2, [R1]        ; estado do missil em R2
        CMP R2, 0       ; verifica se o missil esta attivo (estado-1)
        JZ missil       ; se nao estiver volta ao inicio do ciclo
        MOV R2, [MISSIL_ANDA]       ; lê o LOCK desta instância (bloqueia até a rotina de interrupção)
        CALL anda_missil        ; chama a funcao para mover o missil
        JMP move_missil      ; volta ao início do ciclo


; **********************************************************************
; Processo
;
; Meteoro - Processo responsavel por controlar as ações e evolução
;           de cada um dos meteoros, incluindo verificação de
;           colisões com o míssil ou com o rover.
;
; **********************************************************************
PROCESS SP_inicial_meteoro_0
    meteoro:
        MOV  R10, R11       ; cópia do nº de instância do processo
	    SHL  R10, 1     ; multiplica por 2 porque as tabelas são de WORDS
	    MOV  R9, meteoros_SP_tab        ; tabela com os SPs iniciais das várias instâncias deste processo
	    MOV	SP, [R9+R10]        ; re-inicializa o SP deste processo, de acordo com o nº de instância
				                ; NOTA - Cada processo tem a sua cópia própria do SP
    reset_meteoro:
    CALL torna_bom_ou_mau     ; torna o meteoro bom ou mau aleatoriamente (75% mau, 25% bom)
    MOV R11, 1
    tabela:
        MOV R4, bom_mau     ; tabela com a indica se os meteoros sao bons ou maus
        MOV R2, [R4+R10]        ; informacao que indica se o meteoro eh bom ou mau em R2
        MOV R4, 1
        CMP R4, R2     ; ve se o meteoro e bom
        JZ bom      ; se for salta
        mau:
            MOV	R8, DEF_METEORO_MAU         ; endereço da tabela que contem as varias tabelas de meteoros maus com diferentes tamanhos em R8
            JMP posicao_inicial
        bom:
            MOV	R8, DEF_METEORO_BOM	        ; endereço da tabela que contem as varias tabelas de meteoros bons com diferentes tamanhos em R8
    posicao_inicial:
        MOV R4, 0
        MOV [COLISAO_BALA], R4      ; colisao com bala volta a 0
        MOV [COLIDIU_BOM], R4       ; colisao entre missil e meteoro bom a 0
        MOV R9, linha_meteoro       ; tabela da slinhas dos meteoros em R9
        MOV [R9+R10], R4        ; linha do meteoro volta a 0
        MOV  R1, R4         ; linha em que cada meteoro está
                            ; NOTA - Cada processo tem a sua cópia própria do R1
        MOV  R9, coluna_meteoro     ; tabela das colunas dos meteoros em R9
        CALL gerar_numero_random        ; gera um numero semi-aleatorio de 0 a 8
        SHL R0, 3       ; transforma esse numero num multiplo de 8 de 0 a 64
        MOV [R9+R10], R0        ; esse numero vai corresponde à coluna do meteoro
        MOV R2, R0
		           ; NOTA - Cada processo tem a sua cópia própria do R2
    MOV R3, [R8]        ; tabela do meteoro de tamanho 1x1 em R3
    MOV R9, linha_meteoro       ; tabela das linhas dos meteoros em R9
    ciclo_meteoro:
        CALL desenha_boneco		; desenha o meteoro a partir da sua tabela
        MOV R6, 31
        MOV R1, [R9+R10]        ; linha do boneco em R1
        CMP R1, R6      ; verifica se o boneco passou da linha 32
        JGT morreu_meteoro      ; se passou salta para o destruir
        CALL verifica_missil_meteoro        ; verifica se o meteoro colidiu com um missil
        MOV R5, [COLISAO_BALA]
        CMP R5, 1               ; se o meteoro colidiu com um missil,
        JZ morreu_meteoro       ; salta para o destruir
        CALL verifica_rover_meteoro     ; verifica se o meteoro colidiu com o rover
        MOV R6, [COLIDIU_BOM]   
        CMP R6, 1       ; verifica se o missil colidiu com um meteoro bom
        JZ morreu_bom       ; se sim, salta para o destruir
        MOV  R4, [evento_int_meteoro]       ; lê o LOCK desta instância (bloqueia até a rotina de interrupção)
        CALL tocar_mov
        ADD R11, 1      ; incrementa R11 para saber quantas linhas ja andou o meteoro
        MOV R4, 4
        CMP R11, R4     ; se andou menos de 4 linhas
        JLT e_1     ; salta para usar o meteoro 1x1
        MOV R4, 7
        CMP R11, R4         ; se andou menos de 7 linhas
        JLT e_2     ; salta para usar o meteoro 2x2
        MOV R4, 10
        CMP R11, R4         ; se andou menos de 10 linhas
        JLT e_3     ; salta para usar o meteoro 3x3
        MOV R4, 13
        CMP R11, R4         ; se andou menos de 13 linhas
        JLT e_4     ; salta para usar o meteoro 4x4
        JMP e_5     ; se andou mais do que 12 linhas salta para usar o 5x5
        e_1:
            MOV R3, [R8]        ; usa a tabela 1x1
            JMP proxima_linha
        e_2:
            MOV R3, [R8+2]      ; usa a tabela 2x2
            JMP proxima_linha
        e_3:
            MOV R3, [R8+4]      ; usa a tabela 3x3
            JMP proxima_linha
        e_4:
            MOV R3, [R8+6]      ; usa a tabela 4x4
            JMP proxima_linha
        e_5:
            MOV R3, [R8+8]      ; usa a tabela 5x5
            JMP proxima_linha

        proxima_linha:

        CALL	apaga_pixeis        ; apaga o boneco da sua posição corrente
        MOV R1, [R9+R10]
        ADD	R1, 1       ; para desenhar objeto na linha seguinte
        MOV [R9+R10], R1        ; incrementa a linha do meteoro
        JMP	ciclo_meteoro       ; volta ao inicio do ciclo
        morreu_meteoro:
            MOV R5, DEF_MISSIL      ; tabela do missil em R5
            MOV R4, 2
            MOV R6, 15
            MOV [R5+R4], R6     ; linha do missil a 15, para poder voltar a ser utilizado
            MOV R4, 4
            MOV R6, 50
            MOV [R5+R4], R6     ; coluna do missil a 50 para que fique fora do ecrã e nao interfira com os meteoros 
            morreu_bom:
            CALL apaga_pixeis       ; apaga o meteoro
            MOV R3, [R8+10]         ; coloca a tabela de animacao da colisao em R3
            CALL desenha_boneco     ; desenha a animacao
            CALL ciclo_atraso       ; espera um pouco para que a animacao seja visivel
            CALL ciclo_atraso       ; espera um pouco para que a animacao seja visivel
            CALL apaga_pixeis       ; apaga o meteoro
            CALL desenha_rover      ; para redesenhar o boneco já que o fantasma apaga parte dele ao colidir
            JMP reset_meteoro       ; "cria um novo meteoro"

fim:
    YIELD
    JMP fim


; **********************************************************************
; ciclo_atraso - loop para atrasar o programa
;
; **********************************************************************

ciclo_atraso:
    PUSH R11
    MOV R11, ATRASO
    ciclo_a:
        SUB R11, 1
        JNZ ciclo_a     ; volta ao ciclo enquanto R11 nao for 0
    POP R11
    RET


; **********************************************************************
; desenha_rover - chama a funcao desenha_boneco com os argumentos
;                 necessarios para que esta desenhe o rover
;
; **********************************************************************

desenha_rover:
    PUSH R1
    PUSH R2
    PUSH R3
    MOV R1, LINHA_ROVER     ; coloca a linha do rover em R1
    MOV R2, [COLUNA_ROVER]      ; coloca a coluna do rover em R2
    MOV R3, DEF_ROVER       ; coloca a tabela do rover em R3
    CALL desenha_boneco     ; chama a funcao desenha_boneco
    POP R3
    POP R2
    POP R1
    RET



; **********************************************************************
; desenha_boneco - Rotina para desenhar bonecos
; Argumentos:   R1 - linha inicial
;               R2 - coluna inicial
;               R3 - tabela do boneco
;
; **********************************************************************

desenha_boneco:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    MOV R10, R2               ; guarda a coluna inicial em R10
    MOV R4, [R3]              ; R4 guarda o valor da largura da nave
    ADD R3, 2                 ; passa para o proximo elemento da tabela
    MOV R9, [R3]              ; R9 guarda a altura da nave
    MOV R6, 0                 ; R6 guarda a altura atual da nave
    MOV R8, 0                 ; R8 guarda a largura da linha atual a ser desenhada
    desenha_linha:
        ADD R3, 2                     ; passa para o proximo elemento da tabela
        MOV R5, [R3]                  ; guarda o valor do pixel no R5
        MOV [DEFINE_LINHA], R1        ; indica em qual linha vai ser alterado um pixel
        MOV [DEFINE_COLUNA], R2       ; indica em qual coluna vai ser alterado um pixel
        MOV [DEFINE_PIXEL], R5        ; altera o valor do pixel no sítio indicado
        ADD R2, 1                   ; avança para a proxima coluna
        ADD R8, 1                   ; aumenta a largura atual da linha a ser desenhada
        CMP R8, R4                  ; compara a largura atual da linha com a largura da nave
        JNZ desenha_linha           ; se a larugra atual for igual a largura da nave sai do ciclo
    MOV R8, 0                     ; coloca a largura atual a 0
    ADD R1, 1                     ; avanca para a proxima linha
    MOV R2, R10                   ; coloca a coluna na posicao inicial
    ADD R6, 1                     ; aumenta 1 a altura atual
    CMP R9, R6                    ; compara altura atual com altura da nave
    JNZ desenha_linha             ; no caso de altura atual ser diferente da altura da nave avanca para o desenho da linha seguinte, caso contrario avanca no programa
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET




; **********************************************************************
; apaga_pixeis_meteoro - Chama a funcao apaga_pixeis com
;                        os argumentos necessários para que
;                        esta apague os pixeis do meteoro. Para além disso,
;                        altera o valor da linha do meteoro para quando o
;                        desenhar depois
;
; **********************************************************************

apaga_pixeis_meteoro:
    PUSH R1
    PUSH R2
    PUSH R3
    MOV R1, [LINHA_METEORO]        ; linha do meteoro em R1
    MOV R2, COLUNA_METEORO         ; coluna do meteoro em R2
    MOV R3, DEF_METEORO_MAU_5      ; tabela do meteoro em R3
    CALL apaga_pixeis              ; chama a função para apagar os pixeis
    MOV R1, LINHA_METEORO          ; endereço da linha do meteoro em R1
    MOV R3, [R1]                   ; linha do meteoro em R3
    ADD R3, 1                      ; passa para a linha seguinte
    MOV [R1], R3                   ; guarda a linha atual
    POP R3
    POP R2
    POP R1
    RET


; **********************************************************************
; apaga_pixeis - Rotina para apagar bonecos
; Argumentos:   R1 - linha inicial
;               R2 - coluna inicial
;               R3 - tabela do boneco
;
; **********************************************************************

apaga_pixeis:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    MOV R10, R2
    MOV R4, [R3]           ; R4 guarda o valor da largura do boneco
    ADD R3, 2              ; passa para o proximo elemento da table
    MOV R9, [R3]           ; R9 guarda a altura do boneco
    MOV R6, 0              ; R6 guarda a altura atual do boneco
    MOV R8, 0              ; R8 guarda a largura da linha atual a ser desenhada
    apaga_linha:
        ADD R3, 2                        ; passa para o proximo elemento da table
        MOV R5, 0                        ; guarda o valor do pixel no R5
        MOV [DEFINE_LINHA], R1           ; indica em qual linha vai ser alterado um pixel
        MOV [DEFINE_COLUNA], R2          ; indica em qual coluna vai ser alterado um pixel
        MOV [DEFINE_PIXEL], R5           ; altera o valor do pixel no sítio indicado
        ADD R2, 1                        ; avanca para a proxima coluna
        ADD R8, 1                        ; aumenta a largura atual da linha a ser desenhhada
        CMP R8, R4                       ; compara a largura atual da linha com a largura do boneco
        JNZ apaga_linha                  ; se a largura atual for igual à largura do boneco sai do ciclo
    MOV R8, 0                   ; coloca a largura atual a 0
    ADD R1, 1                   ; avanca para a proxima linha
    MOV R2, R10                 ; coloca a coluna na posicao inicial
    ADD R6, 1                   ; soma 1 à altura atual
    CMP R9, R6                  ; compara altura atual com altura do boneco
    JNZ apaga_linha             ; no caso de a altura atual ser diferente da altura do boneco avanca para o desenho da linha seguinte, caso contrario avanca no programa
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET
; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna
; o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
;
; **********************************************************************
teclado:
	PUSH R2
	PUSH R3
	PUSH R5
	MOV R2, TEC_LIN               ; guarda o endereço do periférico das linhas em R2
	MOV R3, TEC_COL               ; guarda o endereço do periférico das colunas em R3
	MOV R5, MASCARA_MENOR         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6                 ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]                 ; ler do periférico de entrada (colunas)
	AND R0, R5                    ; elimina bits para além dos bits 0-3
	POP	R5
	POP	R3
	POP	R2
	RET


; **********************************************************************
; descobre_tecla - descobre a tecla que foi carregada
; Argumentos:   R6 - linha
;               R0 - coluna
; Devolove a tecla em R8
;
; **********************************************************************

descobre_tecla:
    PUSH R0
    PUSH R6
    PUSH R9
    MOV R8, 0                   ; R8 a zero
    MOV R9, 0                   ; R9 a zero
    converte_linha:             ; coverter a linha num numero de 0-3
        SHR R6, 1               ; avançar o 1 uma unidade para a direita
        ADD R8, 1               ; incrementar o número da linha
        CMP R6, 0               ; comparar o valor de R6 com 0
        JNZ converte_linha      ; volta ao inicio do ciclo se R6 for diferente de 0
        SUB R8, 1               ; subtrai 1 ao número da linha (porque começa na linha 0) e guarda-o em R8
         
    converte_col:                ; coverter a coluna num numero de 0-3
        SHR R0, 1                ; avançar o 1 uma unidade para a direita
        ADD R9, 1                ; incrementar o número da coluna
        CMP R0, 0                ; comparar o valor de R6 com 0
        JNZ converte_col         ; volta ao inicio do ciclo se R6 for diferente de 0
        SUB R9, 1                ; subtrai 1 ao número da coluna (porque começa na linha 0) e guarda-o em R9
         
    SHL R8, 2                    ; 4 vezes número da linha
    ADD R8, R9                   ; ao somar a R8 a coluna obtém-se a tecla em R8
    POP R9
    POP R6
    POP R0
    RET



; **********************************************************************
; verifica - verifica se o rover se encontra no limite do ecrã
; Argumentos - R7 - sentido do movimento
; Devolve R7
;
; **********************************************************************

verifica:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    CMP R7, -1                  ; verifica se o rover se deve mover para esquerda
    JZ verifica_para_esquerda       ; no caso de ele se dever mover para esquerda saltamos para a verificacao dos limites da esquerda
    
    verifica_para_direita:            ; se o rover nao se vai mover para esquerda entao dever-se-à mover para a direita pelo que passamos à verificacao dos limites da direita
        MOV R5, R2                    ; coloca o valor da coluna no R5
        ADD R5, LARGURA_ROVER         ; adiciona o valor da coluna ao da largura do rover
        MOV R1, MAX_COLUNA            ; move o valor maximo da coluna para R1
        CMP R5, R1                    ; compara R1 com R5 para ver se o rover se encontra no limite de largura
        JZ fim_verifica               ; se ele está no limite volta-se ao inicio 
        JMP passou                    ; se não, o rover passou pela verificação
    
    verifica_para_esquerda:    
        MOV R4, MIN_COLUNA            ; coloca a primeira coluna em R4
        CMP R2, R4                    ; compara R2 com R4 para ver a primeira coluna do rover corresponde à primeira coluna do ecrã
        JZ fim_verifica               ; se sim, o rover está no limite esquerdo, pelo que não pode avançar, voltando-se ao início
                                      ; se não, o rover passou pela verificação
    passou:    
        MOV R1, LINHA_ROVER           ; linha do rover em R1
        MOV R3, DEF_ROVER             ; tabela do rover em R3
        CALL apaga_pixeis             ; apaga os pixeis do rover
        ADD R2, R7                    ; soma R2 a R7 para alterar a posição do rover
        MOV [COLUNA_ROVER], R2        ; a coluna do rover é atualizada para R2
        CALL desenha_rover            ; denha o rover na nova posição

    fim_verifica:
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        RET



; **********************************************************************
; incrementa - incrementa o valor apresentado nos displays
;
; **********************************************************************
incrementa:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV R2, [VALOR_DISPLAY]        ; valor dos displays em R2
    MOV R3, 100H
    CMP R2, R3
    JZ fim_incrementa 
    ADD R2, 1       ; somar um a R2
    MOV R3, 0AH         ; coloca 10 para R3
    MOV R4, R2      ; coloca o valor atualizado dos displays para R4
    AND R4, R3      ; obtem a parte do ultimo digito necessario para a verificacao
    CMP R4, R3      ; verifica se o ultimo digito e A
    JNZ fim_incrementa      ; se o ultimo digito nao for A, entao sai da rotina
    MOV R3, 0AH
    SUB R2, R3      ; coloca o ultimo digito a zero
    MOV R3, 10H     
    ADD R2, R3      ; incrementa um ao penultimo digito
    MOV R3, 0A0H
    MOV R4, R2
    AND R4, R3
    CMP R4, R3      ; verifica se o penultimo digito e A
    JNZ fim_incrementa      ; se o penultimo digito nao for A, entao sai da rotina
    MOV R3, 100H        
    ADD R2, R3          ; incrementa um ao antepenutimo digito     
    MOV R3, 0A0H        
    SUB R2, R3      ; coloca zero no penultimo digito
    fim_incrementa:
        MOV [VALOR_DISPLAY], R2           ; alterar o valor dos displays para R2
        MOV [DISPLAYS], R2                ; mostrar nos displays o novo valor
        MOV R1, 2                         ; selecionar a linha
        CALL espera_nao_tecla             ; esperar que não haja nehuma tecla primida nessa linha
        POP R4
        POP R3
        POP R2
        POP R1
        RET


; **********************************************************************
; decrementa - decrementa o valor apresentado nos displays
;
; **********************************************************************
decrementa:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV R2, [VALOR_DISPLAY]          ; valor dos displays em R2
    SUB R2, 1                        ; subtrair um a R2
    MOV R3, 0FH
    MOV R4, R2
    AND R4, R3
    CMP R4, R3       ; verifica se o ultimo digito e F
    JNZ fim_decrementa  ; se o ultimo digito nao for F, sai da rotina
    MOV R4, 6       
    SUB R2,R4       ; coloca 9 no ultimo digito
    MOV R3, 0F0H
    MOV R4, R2
    AND R4, R3
    CMP R4, R3      ; verifica se o penultimo digito e F
    JNZ fim_decrementa ; se o penultimo digito nao for F, sai da rotina
    MOV R4, 60H
    SUB R2,R4       ; coloca 9 no penultimo digito
    fim_decrementa:
        MOV [VALOR_DISPLAY], R2         ; alterar o valor dos displays para R2
        MOV [DISPLAYS], R2              ; mostrar nos displays o novo valor
        MOV R1, 2                       ; selecionar a linha
        CALL espera_nao_tecla           ; esperar que não haja nehuma tecla primida nessa linha
        POP R4
        POP R3
        POP R2
        POP R1
        RET



; **********************************************************************
; espera_nao_tecla - Espera até NÃO haver nenhuma tecla premida na linha
;                    guardada em R6
; Argumentos:   R6 - linha
;
; **********************************************************************

espera_nao_tecla:
    PUSH R0
    espera_nao_tecla_ciclo:
	CALL teclado			           ; leitura às teclas
	CMP	R0, 0                          ; verifica se há alguma tecla a ser primida
	JNZ	espera_nao_tecla_ciclo	       ; espera enquanto houver tecla uma tecla carregada
    POP R0
    RET



; **********************************************************************
; tocar_mov - toca o som 0
; **********************************************************************

tocar_mov:
    PUSH R0
    MOV R0, 0
    MOV [TOCA_SOM], R0                           ; toca o som
    POP R0
    RET

; **********************************************************************
; tocar_disparo - toca o som 1
; **********************************************************************

tocar_disparo:
    PUSH R0
    MOV R0, 1
    MOV [TOCA_SOM], R0                           ; toca o som
    POP R0
    RET

; **********************************************************************
; tocar_derrota - toca o som 2
; **********************************************************************

tocar_derrota:
    PUSH R0
    MOV R0, 2
    MOV [TOCA_SOM], R0                           ; toca o som
    POP R0
    RET

; **********************************************************************
; tocar_fantasma - toca o som 4
; **********************************************************************

tocar_fantasma:
    PUSH R0
    MOV R0, 4
    MOV [TOCA_SOM], R0                           ; toca o som
    POP R0
    RET
; **********************************************************************
; inicia_missil - inicia o missil, alterando os dados na memoria,
;                 mete o estado do missil ativo, atualiza a linha
;                 e a coluna do missil
;
; **********************************************************************
inicia_missil:
    PUSH R0
    PUSH R1
    PUSH R2
    CALL tocar_disparo
    MOV R0, DEF_MISSIL
    MOV R1, 1
    MOV [R0], R1
    MOV R1, LINHA_ROVER
    SUB R1, 1
    ADD R0, 2
    MOV [R0], R1
    MOV R2, [COLUNA_ROVER]
    ADD R2, 1
    ADD R0, 2
    MOV [R0], R2
    POP R2
    POP R1
    POP R0
    RET

; **********************************************************************
; desenha_missil - apaga o missil da posicao anterior 
;                  e desenha ele na nova posicao
;
; **********************************************************************

desenha_missil:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    MOV R0, DEF_MISSIL      ; coloca o endereco das inforamacoes do missil no R0
    ADD R0, 2       ; coloca o endereco da linha do missil no R0
    MOV R1, 2
    MOV [APAGA_ECRA_ESP], R1        ; apaga o missil anterior
    MOV [SELECIONA_DISPLAY], R1     ; escolhe o display do missil
    MOV R1, [R0]        ; coloca a linha do missil no R1
    MOV [DEFINE_LINHA], R1     ; escolhe a linha para desenhar o missil
    SUB R1, 1       ; subtrai 1 a linha do missil, de modo a atualizar 
    MOV [R0], R1        ; coloca a nova linha do missil na memoria
    ADD R0, 2       ; coloca o endereco da coluna do missil no R0
    MOV R2, [R0]        ; coloca a coluna do missil no R2
    MOV [DEFINE_COLUNA], R2     ; escolhe a coluna para desenhar o missil
    ADD R0, 2       ; coloca o endereco da cor do pixel do missil no R0
    MOV R3, [R0]        ; coloca a cor do pixel do missil no R3
    MOV [DEFINE_PIXEL], R3      ; desenha o pixel no novo citio
    MOV R1, 0
    MOV [SELECIONA_DISPLAY], R1     ;volta a escolher o display principal
    POP R3
    POP R2
    POP R1
    POP R0
    RET




; **********************************************************************
; gerar_numero_random - gera um número random e devolve-o em R0
;
; Devolve o número aleatório entre 0 e 7 em R0
;
; **********************************************************************
gerar_numero_random:
    PUSH R1
    MOV R0, [TEC_COL]                  ; lê o valor dos displays
    MOV R1, MASCARA_MAIOR
    AND R0, R1              ; isola os bits de maior peso
    SHR R0, 5               ; coloca os bits nos bits 2-0
    POP R1
    RET


; **********************************************************************
; verifica_rover_meteoro - verifica se houve colisao do rover com um meteoro
;
; **********************************************************************

verifica_rover_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    MOV R1, LINHA_ROVER      ; primeira linha do rover em R1
    MOV R2, [COLUNA_ROVER]      ; primeira coluna do rover em R2
    MOV R7, R1
    ADD R7, 6        ; ultima linha do rover em R7
    MOV R6, R2
    ADD R6, 2      ; ultima coluna do rover em R6
    MOV R5, linha_meteoro
    MOV R3, [R5+R10]      ; primeira linha do meteoro em R3
    MOV R5, coluna_meteoro
    MOV R4, [R5+R10]        ; primeira coluna do meteoro em R4
    MOV R8, R3
    ADD R8, 5        ; linha de baixo do meteoro em R8
    MOV R9, R4
    ADD R9, 4        ; coluna da direita do meteoro em R9
    CMP R3, R7       ; compara a primeira linha do meteoro com a ultima linha do rover
    JGT fim_verifica_rover_meteoro      ; se for maior sai da rotina
    CMP R2, R9        ; compara a primeira coluna do rover com a ultima coluna do meteoro
    JGT fim_verifica_rover_meteoro      ; se for maior sai da rotina
    CMP R1, R8       ; compara a primeira linha do rover com a ultima linha do meteoro
    JGT fim_verifica_rover_meteoro      ; se for maior sai da rotina
    CMP R4, R6       ; compara a primeira coluna do meteoro com a ultima coluna do rover
    JGT fim_verifica_rover_meteoro      ; se for maior sai da rotina

    ; se chegar a este ponto, houve colisao
    MOV R0, 0
    MOV [DEF_MISSIL], R0        ; desativa o missil
    MOV R5, bom_mau
    MOV R6, [R5+R10]        ; informacao sobre se o rover e mau ou bom em R6 (0-mau, 1-bom)
    CMP R6, 0         ; ve se eh mau
    JZ meteoro_e_mau        ; se for mau salta
    CALL incrementa_met_bom     ; se for bom incrementa 10 de energia
    MOV R0, 1
    MOV [COLIDIU_BOM], R0       ; coloca a flag de colisao com meteoro bom a 1
    JMP fim_verifica_rover_meteoro      ; salta para o final

    meteoro_e_mau:
        MOV R0, 3
        MOV [APAGA_ECRA], R0        ; apaga o ecra
        MOV R0, 2
        MOV [GAME_OVER], R0     ; coloca GAME_OVER a 2 (o que indica ao programa que houve uma colisao com um meteoro mau)

    fim_verifica_rover_meteoro:
        POP R10
        POP R9
        POP R8
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET


; **********************************************************************
; incrementa_met_bom - incrementa a energia do rover, na quantia
;                      correspondente a absorcao de um meteoro bom (10)
;
; **********************************************************************
incrementa_met_bom:
    PUSH R0
    MOV R0, 10
    ciclo_met_bom:
        CALL incrementa     ; incrementa a energia 1 vez
        SUB R0, 1       ; subtrai 1 a R0
        CMP R0, 0       ; verifica se R0 ficou a 0
        JNZ ciclo_met_bom       ; se nao, volta ao inicio do ciclo
    POP R0
    RET


; **********************************************************************
; incrementa_met_bom - incrementa a energia do rover, na quantia
;                      correspondente a um tiro que acertou
;                      num meteoro mau (5)
;
; **********************************************************************

incrementa_acertou:
    PUSH R0
    MOV R0, 5
    ciclo_incrementa_acertou:
        CALL incrementa        ; incrementa a energia 1 vez
        SUB R0, 1       ; subtrai 1 a R0
        CMP R0, 0       ; verifica se R0 ficou a 0
        JNZ ciclo_incrementa_acertou        ; se nao, volta ao inicio do ciclo
    POP R0
    RET


; **********************************************************************
; verifica_rover_meteoro - verifica se houve colisao do missil com um meteoro
;
; **********************************************************************

verifica_missil_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R10
    MOV R0, [DEF_MISSIL]        ; tabela do missil em R0
    CMP R0, 0       ; verifica se o missil esta ativo
    JZ fim_verifica_missil_met     ; se nao estiver sai da funcao
    MOV R0, DEF_MISSIL      
    ADD R0, 2
    MOV R1, [R0]        ; linha do missil em R1
    ADD R0, 2
    MOV R2, [R0]        ; coluna do missil em R2
    MOV R5, linha_meteoro
    MOV R3, [R5+R10]       ; linha do meteoro em R3
    MOV R5, coluna_meteoro
    MOV R4, [R5+R10]       ; coluna do meteoro em R4
    ADD R3, 4        ; linha de baixo do meteoro em R3
    CMP R1, R3
    JGT fim_verifica_missil_met     ; se for maior sai da funcao
    CMP R2, R4       ; compara a coluna do missil com a primeira coluna do meteoro
    JLT fim_verifica_missil_met     ; se for menor sai da funcao
    ADD R4, 4       ; coluna da direita do meteoro em R4
    CMP R2, R4       ; compara a coluna do missil com a ultima coluna do meteoro
    JGT fim_verifica_missil_met     ; se for maior sai da funcao

    ; Se chegou ate aqui sem saltar para o final, houve colisao
    MOV R0, 0
    MOV [DEF_MISSIL], R0        ; desativa o missil
    MOV R0, 1
    MOV [COLISAO_BALA], R0      ; flag de colisao com bala passa a um (houve colisao)
    MOV R1, 2
    MOV [APAGA_ECRA_ESP], R1        ; apaga o missil
    MOV R1, 0
    MOV [SELECIONA_DISPLAY], R1     ; seleciona o display principal
    MOV R5, bom_mau
    MOV R6, [R5+R10]         ; informacao sobre o meteoro ser mau ou bom em R6 (0-mau, 1-bom)
    CMP R6, 1       ; verifica se eh bom
    JZ fim_verifica_missil_met      ; se sim, salta para o fim
    CALL tocar_fantasma
    CALL incrementa_acertou     ; se nao, chama a funcao que incrementa a energia por acertar num meteoro mau e depois eh que sai da funcao

    fim_verifica_missil_met:
        POP R10
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET




; **********************************************************************
; torna_bom_ou_mau - Torna o meteoro bom ou mau
;
; Argumentos:   R10 - instancia do processo
;
; **********************************************************************
torna_bom_ou_mau:
    PUSH R0
    PUSH R1
    PUSH R2
    MOV R2, 0
    MOV R1, bom_mau
    CALL gerar_numero_random
    CMP R0, 2
    JLT e_bom
    e_mau:
        MOV [R1+R10], R2
        JMP fim_retorna
    e_bom:
        MOV R2, 1
        MOV [R1+R10], R2
    fim_retorna:
        POP R2
        POP R1
        POP R0
        RET


; **********************************************************************
; anda_missil - Rotina responsavel por fazer mover o missil
;
; **********************************************************************
anda_missil:
    PUSH R0
    PUSH R1
    MOV R0, DEF_MISSIL      ; coloca o endereco das inforamacoes do missil no R0
    MOV R1, [R0]        ; coloca o estado do missil no R1
    CMP R1, 0       ; verifica se o missil esta ativo
    JZ fim_anda_missil       ; se o missil nao estiver ativo, vai para o fim da funcao
    CALL desenha_missil     ; se o missil estiver ativo chama a funcao para desenhar o missil
    MOV R0, DEF_MISSIL      ; coloca o endereco das inforamacoes do missil no R0
    ADD R0, 2           ; coloca o endereco da linha do missil no R0
    MOV R1, [R0]        ; coloca a linha do missil no R1
    MOV R0, 14          ; move o limite da linha para o missil para a R0
    CMP R1, R0          ; compara a linha do missil com a linha limite
    JNZ fim_anda_missil      ; se o missil nao chegou ao limite, 
    MOV R0, 0
    MOV [DEF_MISSIL], R0        ; desativa o missil, se este chegou ao limite
    MOV R1, 2
    MOV [APAGA_ECRA_ESP], R1        ; apaga o missil
    MOV R1, 0
    MOV [SELECIONA_DISPLAY], R1     ; seleciona o display principal
    fim_anda_missil:
    POP R1
    POP R0
    RET

; **********************************************************************
; decrementa_5 - decrementa a energia do rover 5 unidades.
;                Corresponde aos "gastos de funcionamento" do rover
;
; **********************************************************************
decrementa_5:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R5
    MOV R2, 5
    ciclo_decrementa:
        CALL decrementa     ; decrementa a energia 1 unidade
        SUB R2, 1       ; subtrai 1 ao R2
        JNZ ciclo_decrementa        ; enquanto R2 nao for 0, continua no ciclo
        MOV R0, [VALOR_DISPLAY]     ; valor dos displays em R0
        MOV R1, 0
        CMP R0, R1      ; compara o valor dos displays com 0
        JGT fim_decrementa_5        ; se for maior sai da rotina
        manter_energia_0:       ; se nao, mantem a 0
            MOV R2, 0
            MOV [VALOR_DISPLAY], R2     ; valor dos displays a 0
            MOV [DISPLAYS], R2      ; altera o display para 0
            MOV R5, 1
            MOV [GAME_OVER], R5     ; GAME_OVER a 1, para o programa saber que acabou a energia
    fim_decrementa_5:
        POP R5
        POP R2
        POP R1
        POP R0
        RET





; Rotinas de interrupcao



; **********************************************************************
; ROT_MOVER_METEORO - Rotina de atendimento da interrupção 0
;			          Faz o meteoro mover-se
;
; **********************************************************************
rot_mover_meteoro:
    
    PUSH R1
    MOV R1, 1
    MOV [evento_int_meteoro], R1       ; altera o LOCK
    POP R1
    RFE


; **********************************************************************
; ROT_MISSIL - Rotina de atendimento da interrupção 1
;			          Faz o missil mover-se
;
; **********************************************************************
rot_missil:
    PUSH R0
    MOV R0, 1
    MOV [MISSIL_ANDA], R0       ; altera o LOCK
    POP R0
    RFE

; **********************************************************************
; ROT_ENERGIA - Rotina de atendimento da interrupção 2
;			          Faz a energia decrescer
;
; **********************************************************************
rot_energia:
    PUSH R0
    MOV R0, 1
    MOV [DECRESCE_ENERGIA], R0       ; altera o LOCK
    POP R0
    RFE