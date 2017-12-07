-- *************************************************
-- JOGO TETRIS 
-- INSTRUÇÕES:
-- As teclas W e S movimentam o Sapo
-- para cima e para baixo.
-- As teclas A e D movimentam o Sapo 
-- para esquerda e direita.
-- *************************************************
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY notepad IS

	PORT(
		clkvideo, clk, reset  : IN	STD_LOGIC;		
		videoflag	: out std_LOGIC;
		vga_pos		: out STD_LOGIC_VECTOR(15 downto 0);
		vga_char		: out STD_LOGIC_VECTOR(15 downto 0);
		
		key			: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0)	-- teclado
		
		);

END  notepad ;

ARCHITECTURE a OF notepad IS
	--Escreve na tela
	SIGNAL VIDEOE      : STD_LOGIC_VECTOR(7 DOWNTO 0);

	--Formato do bloco
	SIGNAL BLOCOCHAR  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	--Cor do bloco
	SIGNAL BLOCOCOR   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL APAGACOR   : STD_LOGIC_VECTOR(3 DOWNTO 0);
		
	TYPE COR IS ARRAY (3 DOWNTO 0) OF STD_LOGIC;
	TYPE COR_ARRAY IS ARRAY (300 DOWNTO 0) OF COR;
	SIGNAL MAPA : COR_ARRAY;
	
	SIGNAL APAGA_POS   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	--Posicoes que deverao ser desenhadas
	SIGNAL BLOCO1   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BLOCO2   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BLOCO3   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BLOCO4   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	SIGNAL BLOCO1A   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BLOCO2A   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BLOCO3A   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BLOCO4A   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	--Flag que indica se o bloco colidiu
	SIGNAL POUSOU_FLAG : STD_LOGIC;
	
	--Delay do bloco e da movimentacao lateral
	SIGNAL DELAY1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DELAY2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DELAY3      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CONTADOR    : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL SAPOESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL TECLAESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

-- Peças
PROCESS (clk, reset)
	VARIABLE TIPO_PECA : INTEGER := 0;
	VARIABLE TIPO_ROTACAO : INTEGER := 0;
	VARIABLE B1_POS : INTEGER := 0;
	VARIABLE B2_POS : INTEGER := 0;
	VARIABLE B3_POS : INTEGER := 0;
	VARIABLE B4_POS : INTEGER := 0;
	
	BEGIN
	
	IF RESET = '1' THEN
		BLOCOCHAR <= "00000001";
		CONTADOR <= (others =>'0');
		BLOCOCOR <= x"B";
		BLOCO1 <= x"0088";
		BLOCO2 <= x"0089";
		BLOCO3 <= x"00B0";
		BLOCO4 <= x"00B1";
		DELAY1 <= x"00000000";
		DELAY3 <= x"00000000";
		SAPOESTADO <= x"00";
		
	ELSIF (clk'event) and (clk = '1') THEN	
		CONTADOR <= CONTADOR + x"1";
		B1_POS := (conv_integer(BLOCO1)/40) * 10 + (conv_integer(BLOCO1) MOD 40) - 15;
		B2_POS := (conv_integer(BLOCO2)/40) * 10 + (conv_integer(BLOCO2) MOD 40) - 15;
		B3_POS := (conv_integer(BLOCO3)/40) * 10 + (conv_integer(BLOCO3) MOD 40) - 15;
		B4_POS := (conv_integer(BLOCO4)/40) * 10 + (conv_integer(BLOCO4) MOD 40) - 15;
		
		CASE SAPOESTADO IS
			--Descida automatica da peça
			WHEN x"00" =>
			
				--Se nenhum dos blocos tiver atingido o chão
				IF(BLOCO1 < 1159 and BLOCO2 < 1159 and BLOCO3 < 1159 and BLOCO4 < 1159 AND MAPA(B1_POS + 10) = x"0" AND MAPA(B2_POS + 10) = x"0" AND MAPA(B3_POS + 10) = x"0" AND MAPA(B4_POS + 10) = x"0") THEN
					BLOCO1 <= BLOCO1 + x"28";
					BLOCO2 <= BLOCO2 + x"28";
					BLOCO3 <= BLOCO3 + x"28";
					BLOCO4 <= BLOCO4 + x"28";
				--Se algum dos blocos tiver colidido, mande outro bloco
				ELSE
					TIPO_PECA := (conv_integer(BLOCO1) + conv_integer(CONTADOR)) MOD 7;
					--TIPO_PECA := 3;
					TIPO_ROTACAO := 0;
					--Escolhe a peça que será enviada
					CASE (TIPO_PECA) IS
						--  1□ 2□ 3□ 4□
						WHEN 0 =>
							BLOCOCOR <= x"E";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"008A";
							BLOCO4 <= x"008B";
						-- 1□
						-- 2□ 3□ 4□ 
						WHEN 1 =>
							BLOCOCOR <= x"C";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"00B0";
							BLOCO3 <= x"00B1";
							BLOCO4 <= x"00B2";
						--       4□   
						-- 1□ 2□ 3□
						WHEN 2 =>
							BLOCOCOR <= x"F";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"008A";
							BLOCO4 <= x"0062";
						
						-- 1□ 2□
						-- 3□ 4□
						WHEN 3 =>
							BLOCOCOR <= x"B";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"00B0";
							BLOCO4 <= x"00B1";
						
						--    3□ 4□
						-- 1□ 2□
						WHEN 4 =>
							BLOCOCOR <= x"A";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"0061";
							BLOCO4 <= x"0062";
						--    4□
						-- 1□ 2□ 3□
						WHEN 5 =>
							BLOCOCOR <= x"5";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"008A";
							BLOCO4 <= x"0061";
						-- 1□ 2□
						--    3□ 4□
						WHEN 6 =>
							BLOCOCOR <= x"9";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"00B1";
							BLOCO4 <= x"00B2";
						WHEN OTHERS =>
					END CASE;
				END IF;
			
				--Vá para o estado de espera
				SAPOESTADO <= x"01";
			
			--Delay da peça e da movimentacao lateral
			WHEN x"01" =>
				--Se já tiver passado o delay de descida automática
				IF DELAY1 >= x"0000BFFF" THEN
					DELAY1 <= x"00000000";
					SAPOESTADO <= x"00";
				ELSE
					--Se já tiver passado o delay lateral
					IF DELAY3 >= x"0005FFF" and POUSOU_FLAG = '0' THEN
						DELAY3 <= x"00000000";
						
						CASE key IS
							--(A) ESQUERDA	
							WHEN x"61" => 
								IF (NOT((conv_integer(BLOCO1) MOD 40) = 15) and NOT((conv_integer(BLOCO2) MOD 40) = 15) and NOT((conv_integer(BLOCO3) MOD 40) = 15) and NOT((conv_integer(BLOCO4) MOD 40) = 15) and MAPA(B1_POS - 1) = x"0" and MAPA(B2_POS - 1) = x"0" and MAPA(B3_POS - 1) = x"0" and MAPA(B4_POS - 1) = x"0") THEN   -- nao esta' na extrema esquerda
									BLOCO1 <= BLOCO1 - x"01";
									BLOCO2 <= BLOCO2 - x"01";
									BLOCO3 <= BLOCO3 - x"01";
									BLOCO4 <= BLOCO4 - x"01";
								END IF;
							--(D) DIREITA
							WHEN x"64" => 
								IF (NOT(15 + (conv_integer(BLOCO1) MOD 40) = 39) and NOT(15 +(conv_integer(BLOCO2) MOD 40) = 39) and NOT(10 + (conv_integer(BLOCO3) MOD 40) = 39) and NOT(15 +(conv_integer(BLOCO4) MOD 40) = 39) and MAPA(B1_POS + 1) = x"0" and MAPA(B2_POS + 1) = x"0" and MAPA(B3_POS + 1) = x"0" and MAPA(B4_POS + 1) = x"0") THEN   -- nao esta' na extrema direita
									BLOCO1 <= BLOCO1 + x"01";
									BLOCO2 <= BLOCO2 + x"01";
									BLOCO3 <= BLOCO3 + x"01";
									BLOCO4 <= BLOCO4 + x"01";
								END IF;
							--(S) BAIXO
							WHEN x"73" => 
								IF (BLOCO1 < 1159 and BLOCO2 < 1159 and BLOCO3 < 1159 and BLOCO4 < 1159 AND MAPA(B1_POS + 10) = x"0" AND MAPA(B2_POS + 10) = x"0" AND MAPA(B3_POS + 10) = x"0" AND MAPA(B4_POS + 10) = x"0") THEN
									BLOCO1 <= BLOCO1 + x"28";
									BLOCO2 <= BLOCO2 + x"28";
									BLOCO3 <= BLOCO3 + x"28";
									BLOCO4 <= BLOCO4 + x"28";
								END IF;
							--(W) CIMA
							WHEN x"77" => 
								CASE TIPO_PECA IS
									WHEN 0 =>
										--  1□ 2□ 3□ 4□
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO3 - x"50";
											BLOCO2 <= BLOCO3 - x"28";
											BLOCO4 <= BLOCO3 + x"28";
										ELSE
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO3 - x"02";
											BLOCO2 <= BLOCO3 - x"01";
											BLOCO4 <= BLOCO3 + x"01";
										END IF;
									WHEN 1 =>
										--                   2□ 1□
										-- 1□                3□
										-- 2□ 3□ 4□ ----->   4□
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO3 - x"29";
											BLOCO2 <= BLOCO3 - x"28";
											BLOCO4 <= BLOCO3 + x"28";
										
										-- □ □     
										-- □     ----->   □ □ □
										-- □                  □
										ELSIF(TIPO_ROTACAO = 1) THEN
											TIPO_ROTACAO := 2;
											BLOCO1 <= BLOCO3 + x"29";
											BLOCO2 <= BLOCO3 + x"01";
											BLOCO4 <= BLOCO3 - x"01";
										
										--                     4□
										-- 4□ 3□ 2□  ----->    3□
										--       1□         1□ 2□
										ELSIF(TIPO_ROTACAO = 2) THEN
											TIPO_ROTACAO := 3;
											BLOCO1 <= BLOCO3 + x"27";
											BLOCO2 <= BLOCO3 + x"28";
											BLOCO4 <= BLOCO3 - x"28";
										
										--    4□
										--    3□ -----> 1□ 
										-- 1□ 2□        2□ 3□ 4□  
										ELSIF(TIPO_ROTACAO = 3) THEN
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO3 - x"29";
											BLOCO2 <= BLOCO3 - x"01";
											BLOCO4 <= BLOCO3 + x"01";
										END IF;
									WHEN 2 =>
										--                   1□  
										--        4□  -----> 2□
										--  1□ 2□ 3□         3□ 4□
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO2 - x"28";
											BLOCO3 <= BLOCO2 + x"28";
											BLOCO4 <= BLOCO2 + x"29";
											
										--  1□  
										--  2□      ----->  3□ 2□ 1□
										--  3□ 4□           4□
										ELSIF(TIPO_ROTACAO = 1) THEN 
											TIPO_ROTACAO := 2;
											BLOCO1 <= BLOCO2 + x"01";
											BLOCO3 <= BLOCO2 - x"01";
											BLOCO4 <= BLOCO2 + x"27";
										--                   4□ 3□
										--  3□ 2□ 1□ ----->     2□
										--  4□                  1□
										ELSIF(TIPO_ROTACAO = 2) THEN 
											TIPO_ROTACAO := 3;
											BLOCO1 <= BLOCO2 + x"28";
											BLOCO3 <= BLOCO2 - x"28";
											BLOCO4 <= BLOCO2 - x"29";
										--  4□ 3□         
										--     2□   ---->       4□
										--     1□         1□ 2□ 3□
										ELSIF(TIPO_ROTACAO = 3) THEN 
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO2 - x"01";
											BLOCO3 <= BLOCO2 + x"01";
											BLOCO4 <= BLOCO2 - x"27";
										END IF;						
									WHEN 4 =>
									   --               1□
										--    3□ 4□ ---> 2□ 3□
										-- 1□ 2□            4□
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO2 - x"28";
											BLOCO3 <= BLOCO2 + x"01";
											BLOCO4 <= BLOCO2 + x"29";
											
										--  1□
										--  2□ 3□ --->      2□ 1□
										--     4□        4□ 3□
										ELSIF(TIPO_ROTACAO = 1) THEN 
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO2 + x"01";
											BLOCO3 <= BLOCO2 + x"28";
											BLOCO4 <= BLOCO2 + x"27";
										END IF;		
									WHEN 5 =>
										--                  1□  
										--     4□    -----> 2□ 4□
										--  1□ 2□ 3□        3□ 
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO2 - x"28";
											BLOCO3 <= BLOCO2 + x"28";
											BLOCO4 <= BLOCO2 + x"01";
											
										-- 1□  
										-- 2□ 4□ ------> 3□ 2□ 1□
										-- 3□               4□
										ELSIF(TIPO_ROTACAO = 1) THEN 
											TIPO_ROTACAO := 2;
											BLOCO1 <= BLOCO2 + x"01";
											BLOCO3 <= BLOCO2 - x"01";
											BLOCO4 <= BLOCO2 + x"28";
										--                      3□
										-- 3□ 2□ 1□ ------>  4□ 2□
										--    4□                1□
										ELSIF(TIPO_ROTACAO = 2) THEN 
											TIPO_ROTACAO := 3;
											BLOCO1 <= BLOCO2 + x"28";
											BLOCO3 <= BLOCO2 - x"28";
											BLOCO4 <= BLOCO2 - x"01";
										--    3□
										-- 4□ 2□ -------->     4□
										--    1□            1□ 2□ 3□              
										ELSIF(TIPO_ROTACAO = 3) THEN 
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO2 - x"01";
											BLOCO3 <= BLOCO2 + x"01";
											BLOCO4 <= BLOCO2 - x"28";
										END IF;	
									WHEN 6 =>
										--                    1□
										-- 1□ 2□   ------> 3□ 2□  
										--    3□ 4□        4□
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO2 - x"28";
											BLOCO3 <= BLOCO2 - x"01";
											BLOCO4 <= BLOCO2 + x"27";
											
										--     1□
										--  3□ 2□ ---> 4□ 3□
										--  4□            2□ 1□
										ELSIF(TIPO_ROTACAO = 1) THEN 
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO2 + x"01";
											BLOCO3 <= BLOCO2 - x"28";
											BLOCO4 <= BLOCO2 - x"29";
										END IF;	
									WHEN OTHERS =>
								END CASE;
							WHEN OTHERS => 	
						END CASE;
					ELSE
						DELAY3 <= DELAY3 + x"01";
					END IF;
					DELAY1 <= DELAY1 + x"01";
				END IF;
			WHEN OTHERS => 
		END CASE;
	END IF;
END PROCESS;


-- Escreve na Tela
PROCESS (clkvideo, reset)
	VARIABLE POS_APAGAR    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	VARIABLE COLOR : COR := x"0";
	
	VARIABLE LINHA_B1 : INTEGER := 0;
	VARIABLE LINHA_B2 : INTEGER := 0;
	VARIABLE LINHA_B3 : INTEGER := 0;
	VARIABLE LINHA_B4 : INTEGER := 0;
	
	VARIABLE FLAG_B1 : STD_LOGIC := '0';
	VARIABLE FLAG_B2 : STD_LOGIC := '0';
	VARIABLE FLAG_B3 : STD_LOGIC := '0';
	VARIABLE FLAG_B4 : STD_LOGIC := '0';
	
	VARIABLE APAGAR_POS : INTEGER := 0;
	
	VARIABLE COLUNAS : INTEGER := 0;
	VARIABLE B1_POS : INTEGER := 0;
	VARIABLE B2_POS : INTEGER := 0;
	VARIABLE B3_POS : INTEGER := 0;
	VARIABLE B4_POS : INTEGER := 0;
BEGIN
	IF RESET = '1' THEN
		VIDEOE <= x"00";
		APAGA_POS <= x"000F";
		videoflag <= '0';
		POUSOU_FLAG <= '0';
		MAPA <= (others => x"0");

		ELSIF (clkvideo'event) and (clkvideo = '1') THEN
		CASE VIDEOE IS
			-- Apaga B1
			WHEN x"00" =>			
				IF(BLOCO1 = BLOCO1A) THEN
					VIDEOE <= x"00";
				ELSIF(POUSOU_FLAG = '1') THEN
					VIDEOE <= x"04";
				ELSE
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					vga_pos(15 downto 0)	<= BLOCO1A;
						
					videoflag <= '1';
					VIDEOE <= x"01";
				END IF;
			
			WHEN x"01" =>
				videoflag <= '0';
				VIDEOE <= x"02";
				
			-- Apaga B2
			WHEN x"02" =>
				vga_pos(15 downto 0)	<= BLOCO2A;
				videoflag <= '1';
				VIDEOE <= x"03";
			
			WHEN x"03" =>
				videoflag <= '0';
				VIDEOE <= x"04";
				
			-- Apaga B3
			WHEN x"04" => 			
				vga_pos(15 downto 0)	<= BLOCO3A;
				videoflag <= '1';
				VIDEOE <= x"05";
				
			WHEN x"05" =>
				videoflag <= '0';
				VIDEOE <= x"06";
			
			-- Apaga B4
			WHEN x"06" => 			
				vga_pos(15 downto 0)	<= BLOCO4A;
				videoflag <= '1';
				VIDEOE <= x"07";
				
			WHEN x"07" =>
				videoflag <= '0';
				VIDEOE <= x"08";
			
			-- Desenha B1
			WHEN x"08" =>
				IF(POUSOU_FLAG = '1') THEN
					POUSOU_FLAG <= '0';
				END IF;
			
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= BLOCOCOR;
				vga_char(7 downto 0) <= BLOCOCHAR;
				vga_pos(15 downto 0)	<= BLOCO1;
				BLOCO1A <= BLOCO1;
				videoflag <= '1';
				VIDEOE <= x"09";
				
			WHEN x"09" =>
				videoflag <= '0';
				VIDEOE <= x"0A";
			
			-- Desenha B2
			WHEN x"0A" =>
				vga_pos(15 downto 0)	<= BLOCO2;
				BLOCO2A <= BLOCO2;
				videoflag <= '1';
				VIDEOE <= x"0B";
				
			WHEN x"0B" =>
				videoflag <= '0';
				VIDEOE <= x"0C";
				
			-- Desenha B3
			WHEN x"0C" =>
				vga_pos(15 downto 0)	<= BLOCO3;
				BLOCO3A <= BLOCO3;
				videoflag <= '1';
				VIDEOE <= x"BB";
				
			WHEN x"BB" =>
				vga_pos(15 downto 0)	<= BLOCO4;
				BLOCO4A <= BLOCO4;
				videoflag <= '1';
				VIDEOE <= x"0D";
			
			WHEN x"0D" =>
				--Calcula a posição no vetor reduzido
				B1_POS := (conv_integer(BLOCO1)/40) * 10 + (conv_integer(BLOCO1) MOD 40) - 15;
				B2_POS := (conv_integer(BLOCO2)/40) * 10 + (conv_integer(BLOCO2) MOD 40) - 15;
				B3_POS := (conv_integer(BLOCO3)/40) * 10 + (conv_integer(BLOCO3) MOD 40) - 15;
				B4_POS := (conv_integer(BLOCO4)/40) * 10 + (conv_integer(BLOCO4) MOD 40) - 15;
				
				--Calcula posição inicial da linha
				LINHA_B1 := (B1_POS / 10) * 10;
				LINHA_B2 := (B2_POS / 10) * 10;
				LINHA_B3 := (B3_POS / 10) * 10;
				LINHA_B4 := (B4_POS / 10) * 10;
				videoflag <= '0';
				VIDEOE <= x"0E";
				
			WHEN x"0E" => -- Desenha B4
				VIDEOE <= x"0F";
				IF(NOT(BLOCO1 < 1159 and BLOCO2 < 1159 and BLOCO3 < 1159 and BLOCO4 < 1159 AND MAPA(B1_POS + 10) = x"0" AND MAPA(B2_POS + 10) = x"0" AND MAPA(B3_POS + 10) = x"0" AND MAPA(B4_POS + 10) = x"0")) THEN
						IF(BLOCOCOR = x"E") THEN
							COLOR := x"E";
						ELSIF (BLOCOCOR = x"C") THEN
							COLOR := x"C";
						ELSIF (BLOCOCOR = x"E") THEN
							COLOR := x"E";
						ELSIF (BLOCOCOR = x"F") THEN
							COLOR := x"F";
						ELSIF (BLOCOCOR = x"B") THEN
							COLOR := x"B";
						ELSIF (BLOCOCOR = x"A") THEN
							COLOR := x"A";
						ELSIF (BLOCOCOR = x"5") THEN
							COLOR := x"5";
						ELSE
							COLOR := x"9";
						END IF;
						
						MAPA(B1_POS) <= COLOR;
						MAPA(B2_POS) <= COLOR;
						MAPA(B3_POS) <= COLOR;
						MAPA(B4_POS) <= COLOR;
						POUSOU_FLAG <= '1';
						VIDEOE <= x"A0";
				END IF;
			
			WHEN x"0F" =>
				videoflag <= '0';
				VIDEOE <= x"00";
				
			--Verifica se a linha de b1 está completa
			WHEN x"A0" =>
				--Se todas as posições da linha estiverem ocupadas
				IF(NOT(MAPA(LINHA_B1 + 1) = x"0") AND NOT(MAPA(LINHA_B1 + 2) = x"0") AND NOT(MAPA(LINHA_B1 + 3) = x"0") AND NOT(MAPA(LINHA_B1 + 4) = x"0") AND NOT(MAPA(LINHA_B1 + 5) = x"0") AND NOT(MAPA(LINHA_B1 + 6) = x"0") AND NOT(MAPA(LINHA_B1 + 7) = x"0") AND NOT(MAPA(LINHA_B1 + 8) = x"0") AND NOT(MAPA(LINHA_B1 + 9) = x"0") AND NOT(MAPA(LINHA_B1) = x"0")) THEN
						FLAG_B1 := '1';
				END IF;
				
				VIDEOE <= x"A1";
				
			--Verifica se a linha de b2 está completa
			WHEN x"A1" =>
				--Se todas as posições da linha estiverem ocupadas
				IF(NOT(LINHA_B2 = LINHA_B1) AND NOT(MAPA(LINHA_B2 + 1) = x"0") AND NOT(MAPA(LINHA_B2 + 2) = x"0") AND NOT(MAPA(LINHA_B2 + 3) = x"0") AND NOT(MAPA(LINHA_B2 + 4) = x"0") AND NOT(MAPA(LINHA_B2 + 5) = x"0") AND NOT(MAPA(LINHA_B2 + 6) = x"0") AND NOT(MAPA(LINHA_B2 + 7) = x"0") AND NOT(MAPA(LINHA_B2 + 8) = x"0") AND NOT(MAPA(LINHA_B2 + 9) = x"0") AND NOT(MAPA(LINHA_B2) = x"0")) THEN
						FLAG_B2 := '1';
				END IF;
				
				VIDEOE <= x"A2";
			
			--Verifica se a linha de b3 está completa
			WHEN x"A2" =>
				--Se todas as posições da linha estiverem ocupadas
				IF(NOT(LINHA_B3 = LINHA_B1) AND NOT(LINHA_B3 = LINHA_B2) AND NOT(MAPA(LINHA_B3 + 1) = x"0") AND NOT(MAPA(LINHA_B3 + 2) = x"0") AND NOT(MAPA(LINHA_B3 + 3) = x"0") AND NOT(MAPA(LINHA_B3 + 4) = x"0") AND NOT(MAPA(LINHA_B3 + 5) = x"0") AND NOT(MAPA(LINHA_B3 + 6) = x"0") AND NOT(MAPA(LINHA_B3 + 7) = x"0") AND NOT(MAPA(LINHA_B3 + 8) = x"0") AND NOT(MAPA(LINHA_B3 + 9) = x"0") AND NOT(MAPA(LINHA_B3) = x"0")) THEN
						FLAG_B3 := '1';
				END IF;
				
				VIDEOE <= x"A3";
			
			--Verifica se a linha de b2 está completa
			WHEN x"A3" =>
				--Se todas as posições da linha estiverem ocupadas
				IF(NOT(LINHA_B4 = LINHA_B1) AND NOT(LINHA_B4 = LINHA_B2) AND NOT(LINHA_B4 = LINHA_B3) AND NOT(MAPA(LINHA_B4 + 1) = x"0") AND NOT(MAPA(LINHA_B4 + 2) = x"0") AND NOT(MAPA(LINHA_B4 + 3) = x"0") AND NOT(MAPA(LINHA_B4 + 4) = x"0") AND NOT(MAPA(LINHA_B4 + 5) = x"0") AND NOT(MAPA(LINHA_B4 + 6) = x"0") AND NOT(MAPA(LINHA_B4 + 7) = x"0") AND NOT(MAPA(LINHA_B4 + 8) = x"0") AND NOT(MAPA(LINHA_B4 + 9) = x"0") AND NOT(MAPA(LINHA_B4) = x"0")) THEN
						FLAG_B4 := '1';
				END IF;
				
				LINHA_B1 := LINHA_B1 + 9;
				LINHA_B2 := LINHA_B2 + 9;
				LINHA_B3 := LINHA_B3 + 9;
				LINHA_B4 := LINHA_B4 + 9;
				
				VIDEOE <= x"A4";
			
			--Shifta todos os blocos para baixo
			WHEN x"A4" =>
				IF(LINHA_B1 <= 20 OR FLAG_B1 = '0') THEN
					FLAG_B1 := '0';
					VIDEOE <= x"A5";
				ELSE
					MAPA(LINHA_B1) <= MAPA(LINHA_B1 - 10);
					LINHA_B1 := LINHA_B1 - 1;
				END IF;
			--Shifta todos os blocos para baixo
			WHEN x"A5" =>
				IF(LINHA_B2 <= 20 OR FLAG_B2 = '0') THEN
					FLAG_B2 := '0';
					VIDEOE <= x"A6";
				ELSE
					MAPA(LINHA_B2) <= MAPA(LINHA_B2 - 10);
					LINHA_B2 := LINHA_B2 - 1;
				END IF;
			--Shifta todos os blocos para baixo
			WHEN x"A6" =>
				IF(LINHA_B3 <= 20 OR FLAG_B3 = '0') THEN
					FLAG_B3 := '0';
					VIDEOE <= x"A7";
				ELSE
					MAPA(LINHA_B3) <= MAPA(LINHA_B3 - 10);
					LINHA_B3 := LINHA_B3 - 1;
				END IF;
				
			--Shifta todos os blocos para baixo
			WHEN x"A7" =>
				IF(LINHA_B4 <= 20 OR FLAG_B4 = '0') THEN
					FLAG_B4 := '0';
					VIDEOE <= x"A8";
				ELSE
					MAPA(LINHA_B4) <= MAPA(LINHA_B4 - 10);
					LINHA_B4 := LINHA_B4 - 1;
				END IF;
				
			--Redesenha a Tela
			WHEN x"A8" =>
				IF(COLUNAS = 30)THEN
					COLUNAS := 0;
					VIDEOE <= x"0F";
					APAGA_POS <= x"000F";
				ELSE	
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= APAGACOR;
					vga_char(7 downto 0) <= BLOCOCHAR;
					vga_pos(15 downto 0)	<= APAGA_POS;
					
					--Incrementa a posicao
					APAGA_POS <= APAGA_POS +  x"01";
					videoflag <= '1';
					VIDEOE <= x"A9";
				END IF;
			WHEN x"A9" =>
				IF(conv_integer(APAGA_POS) MOD 40 >= 25) THEN
					APAGA_POS <= APAGA_POS + x"1E";
					COLUNAS := COLUNAS + 1;
				END IF;
				videoflag <= '0';
				VIDEOE <= x"AA";
			WHEN x"AA" =>
				APAGAR_POS := (conv_integer(APAGA_POS)/40) * 10 + (conv_integer(APAGA_POS) MOD 40) - 15;
				videoflag <= '0';
				VIDEOE <= x"AB";
			WHEN x"AB" =>
				IF(MAPA(APAGAR_POS) = x"E") THEN
					APAGACOR <= x"E";
				ELSIF (MAPA(APAGAR_POS) = x"C") THEN
					APAGACOR <= x"C";
				ELSIF (MAPA(APAGAR_POS) = x"0") THEN
					APAGACOR <= x"0";
				ELSIF (MAPA(APAGAR_POS) = x"F") THEN
					APAGACOR <= x"F";
				ELSIF (MAPA(APAGAR_POS) = x"B") THEN
					APAGACOR <= x"B";
				ELSIF (MAPA(APAGAR_POS) = x"A") THEN
					APAGACOR <= x"A";
				ELSIF (MAPA(APAGAR_POS) = x"5") THEN
					APAGACOR <= x"5";
				ELSE
					APAGACOR <= x"9";
				END IF;
			
				VIDEOE <= x"A8";
				videoflag <= '0';
			WHEN OTHERS =>
		END CASE;
	END IF;
END PROCESS;

END a;