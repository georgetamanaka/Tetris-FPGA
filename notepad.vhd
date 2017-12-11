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
	
	--Pontuação
	SIGNAL PONTUACAO	 : STD_LOGIC_VECTOR(14 DOWNTO 0);
	SIGNAL PONTUACAOA  : STD_LOGIC_VECTOR(14 DOWNTO 0);
	
	--Formato do bloco
	SIGNAL BLOCOCHAR  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	--Cor do bloco
	SIGNAL BLOCOCOR   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL APAGACOR   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	TYPE COR_ARRAY IS ARRAY (239 DOWNTO 0) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
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
	SIGNAL DELAY1      : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL DELAY3      : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL CONTADOR    : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL SAPOESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL TECLAESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL PROXESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
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
		BLOCOCOR <= x"A";
		BLOCO1 <= x"0088";
		BLOCO2 <= x"0089";
		BLOCO3 <= x"00B0";
		BLOCO4 <= x"00B1";
		DELAY1 <= x"0000";
		DELAY3 <= x"0000";
		SAPOESTADO <= x"00";

		
	ELSIF (clk'event) and (clk = '1') THEN	
		B1_POS := ((conv_integer(BLOCO1) - 135)/40) * 10 + ((conv_integer(BLOCO1) - 15) MOD 40);
		B2_POS := ((conv_integer(BLOCO2) - 135)/40) * 10 + ((conv_integer(BLOCO2) - 15) MOD 40);
		B3_POS := ((conv_integer(BLOCO3) - 135)/40) * 10 + ((conv_integer(BLOCO3) - 15) MOD 40);
		B4_POS := ((conv_integer(BLOCO4) - 135)/40) * 10 + ((conv_integer(BLOCO4) - 15) MOD 40);
		
		CASE SAPOESTADO IS
			--Descida automatica da peça
			WHEN x"00" =>
			
				--Se nenhum dos blocos tiver atingido o chão
				IF(BLOCO1 < 1039 and BLOCO2 < 1039 and BLOCO3 < 1039 and BLOCO4 < 1039 AND MAPA(B1_POS + 10) = x"0" AND MAPA(B2_POS + 10) = x"0" AND MAPA(B3_POS + 10) = x"0" AND MAPA(B4_POS + 10) = x"0") THEN
					BLOCO1 <= BLOCO1 + x"28";
					BLOCO2 <= BLOCO2 + x"28";
					BLOCO3 <= BLOCO3 + x"28";
					BLOCO4 <= BLOCO4 + x"28";
				--Se algum dos blocos tiver colidido, mande outro bloco
				ELSE
					TIPO_PECA := (conv_integer(BLOCO4A) * conv_integer(BLOCO1) + conv_integer(CONTADOR)/conv_integer(BLOCO2)) MOD 7;
					--TIPO_PECA := 0; -- MUDANCA 1 
					TIPO_ROTACAO := 0;
					--Escolhe a peça que será enviada
					CASE (TIPO_PECA) IS
						--  1□ 2□ 3□ 4□
						WHEN 0 =>
							BLOCOCOR <= x"9";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"008A";
							BLOCO4 <= x"008B";
						-- 1□
						-- 2□ 3□ 4□ 
						WHEN 1 =>
							BLOCOCOR <= x"3";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"00B0";
							BLOCO3 <= x"00B1";
							BLOCO4 <= x"00B2";
						--       4□   
						-- 1□ 2□ 3□
						WHEN 2 =>
							BLOCOCOR <= x"B";
							BLOCO1 <= x"00B5";
							BLOCO2 <= x"00B6";
							BLOCO3 <= x"00B7";
							BLOCO4 <= x"008F";
						
						-- 1□ 2□
						-- 3□ 4□
						WHEN 3 =>
							BLOCOCOR <= x"A";
							BLOCO1 <= x"0088";
							BLOCO2 <= x"0089";
							BLOCO3 <= x"00B0";
							BLOCO4 <= x"00B1";
						
						--    3□ 4□
						-- 1□ 2□
						WHEN 4 =>
							BLOCOCOR <= x"F";
							BLOCO1 <= x"00B2";
							BLOCO2 <= x"00B3";
							BLOCO3 <= x"008B";
							BLOCO4 <= x"008C";
						--    4□
						-- 1□ 2□ 3□
						WHEN 5 =>
							BLOCOCOR <= x"E";
							BLOCO1 <= x"00B2";
							BLOCO2 <= x"00B3";
							BLOCO3 <= x"00B4";
							BLOCO4 <= x"008B";
						-- 1□ 2□
						--    3□ 4□
						WHEN 6 =>
							BLOCOCOR <= x"C";
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
				IF DELAY1 >= x"BFFF" THEN
					DELAY1 <= x"0000";
					SAPOESTADO <= x"00";
				ELSE
					--Se já tiver passado o delay lateral
					IF DELAY3 >= x"5FFF" and POUSOU_FLAG = '0' THEN
						DELAY3 <= x"0000";
						
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
								IF (NOT((conv_integer(BLOCO1) MOD 40) = 24) and NOT((conv_integer(BLOCO2) MOD 40) = 24) and NOT((conv_integer(BLOCO3) MOD 40) = 24) and NOT((conv_integer(BLOCO4) MOD 40) = 24) and MAPA(B1_POS + 1) = x"0" and MAPA(B2_POS + 1) = x"0" and MAPA(B3_POS + 1) = x"0" and MAPA(B4_POS + 1) = x"0") THEN   -- nao esta' na extrema direita
									BLOCO1 <= BLOCO1 + x"01";
									BLOCO2 <= BLOCO2 + x"01";
									BLOCO3 <= BLOCO3 + x"01";
									BLOCO4 <= BLOCO4 + x"01";
								END IF;
							--(S) BAIXO
							WHEN x"73" => 
								IF (BLOCO1 < 999 and BLOCO2 < 999 and BLOCO3 < 999 and BLOCO4 < 999 AND MAPA(B1_POS + 20) = x"0" AND MAPA(B2_POS + 20) = x"0" AND MAPA(B3_POS + 20) = x"0" AND MAPA(B4_POS + 20) = x"0") THEN
									BLOCO1 <= BLOCO1 + x"50";
									BLOCO2 <= BLOCO2 + x"50";
									BLOCO3 <= BLOCO3 + x"50";
									BLOCO4 <= BLOCO4 + x"50";
								END IF;
							--(W) CIMA
							WHEN x"77" => 
								CASE TIPO_PECA IS
									WHEN 0 =>
										--								1□
										--  							2□
										-- 1□ 2□ 3□ 4□ ------>  3□
										--  							4□ 
										IF(TIPO_ROTACAO = 0) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO3 - x"50";
											BLOCO2 <= BLOCO3 - x"28";
											BLOCO4 <= BLOCO3 + x"28";
										--	 1□
										--  2□
										--  3□
										--  4□ 	
										ELSIF((((conv_integer(BLOCO3)) mod 40) - 2 > 14) and ((conv_integer(BLOCO3) mod 40) + 1 < 25)) THEN
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
											BLOCO1 <= BLOCO3 - x"27";
											BLOCO2 <= BLOCO3 - x"28";
											BLOCO4 <= BLOCO3 + x"28";
										
										-- 2□ 1□     
										-- 3□     ----->   4□ 3□ 2□
										-- 4□                    1□
										ELSIF(TIPO_ROTACAO = 1 and conv_integer(BLOCO3) mod 40 > 15) THEN
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
										ELSIF(TIPO_ROTACAO = 3 AND conv_integer(BLOCO3) mod 40 < 24 ) THEN
											TIPO_ROTACAO := 0;
											BLOCO1 <= BLOCO3 - x"29";
											BLOCO2 <= BLOCO3 - x"01";
											BLOCO4 <= BLOCO3 + x"01";
										END IF;
									WHEN 2 =>
										--                   1□  
										--        4□  -----> 2□
										--  1□ 2□ 3□         3□ 4□
										IF(TIPO_ROTACAO = 0 and conv_integer(BLOCO3) mod 40 < 24 ) THEN
											TIPO_ROTACAO := 1;
											BLOCO1 <= BLOCO2 - x"28";
											BLOCO3 <= BLOCO2 + x"28";
											BLOCO4 <= BLOCO2 + x"29";
											
										--  1□  
										--  2□      ----->  3□ 2□ 1□
										--  3□ 4□           4□
										ELSIF(TIPO_ROTACAO = 1 and conv_integer(BLOCO3) mod 40 < 24) THEN 
											TIPO_ROTACAO := 2;
											BLOCO1 <= BLOCO2 + x"01";
											BLOCO3 <= BLOCO2 - x"01";
											BLOCO4 <= BLOCO2 + x"27";
										--                   4□ 3□
										--  3□ 2□ 1□ ----->     2□
										--  4□                  1□
										ELSIF(TIPO_ROTACAO = 2 and conv_integer(BLOCO3) mod 40 > 15) THEN 
											TIPO_ROTACAO := 3;
											BLOCO1 <= BLOCO2 + x"28";
											BLOCO3 <= BLOCO2 - x"28";
											BLOCO4 <= BLOCO2 - x"29";
										--  4□ 3□         
										--     2□   ---->       4□
										--     1□         1□ 2□ 3□
										ELSIF(TIPO_ROTACAO = 3 and conv_integer(BLOCO3) mod 40 > 15) THEN 
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
										ELSIF(TIPO_ROTACAO = 1 and conv_integer(BLOCO2) mod 40 > 15) THEN 
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
										ELSIF(TIPO_ROTACAO = 1 and conv_integer(BLOCO2) mod 40 > 15) THEN 
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
										ELSIF(TIPO_ROTACAO = 3 and conv_integer(BLOCO2) mod 40 < 24) THEN 
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
										ELSIF(TIPO_ROTACAO = 1 and conv_integer(BLOCO2) mod 40 < 24) THEN 
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
	
	VARIABLE B1_POS : INTEGER := 0;
	VARIABLE B2_POS : INTEGER := 0;
	VARIABLE B3_POS : INTEGER := 0;
	VARIABLE B4_POS : INTEGER := 0;
	VARIABLE FLAG_B1 : STD_LOGIC := '0';
	VARIABLE FLAG_B2 : STD_LOGIC := '0';
	VARIABLE FLAG_B3 : STD_LOGIC := '0';
	VARIABLE FLAG_B4 : STD_LOGIC := '0';
	VARIABLE FLAG_GO : STD_LOGIC := '0';
	VARIABLE APAGAR_POS : INTEGER := 0;
	VARIABLE COLUNAS : INTEGER := 0;
	
	VARIABLE PONT : INTEGER := 0;
BEGIN
	IF RESET = '1' THEN
		PONTUACAO <= "000000000000000";
		VIDEOE <= x"30";
		APAGA_POS <= x"0087";
		videoflag <= '0';
		POUSOU_FLAG <= '0';
		FLAG_GO := '0';
		
		ELSIF (clkvideo'event) and (clkvideo = '1') THEN
		CASE VIDEOE IS
			WHEN x"30" =>
					for i in 0 to 239 loop
						MAPA(i) <= x"0"; 
					end loop;
					VIDEOE <= x"A9";
	
			-- Imprime o primeiro digito da pontuação
			WHEN x"31" =>
					PONT := (conv_integer(PONTUACAO) MOD 10) + 48;
			
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "1111";
					vga_char(7 downto 0) <= conv_std_logic_vector(PONT,8);
					vga_pos(15 downto 0)	<= conv_std_logic_vector(70, 16);	
					
					videoflag <= '1';
					PONTUACAOA <= PONTUACAO;
					VIDEOE <= x"DF";
					PROXESTADO <= x"33";
				
			-- Imprime o segundo dígito da pontuação
			WHEN x"33" =>
					PONT := ((conv_integer(PONTUACAO) / 10) MOD 10) + 48;
			
					vga_char(15 downto 12) <= "0000";
					vga_char(7 downto 0) <= conv_std_logic_vector(PONT,8);
					vga_pos(15 downto 0)	<= conv_std_logic_vector(69, 16);	
					
					videoflag <= '1';
					PONTUACAOA <= PONTUACAO;
					VIDEOE <= x"DF";
					PROXESTADO <= x"35";
					
			-- Imprime o terceiro dígito da pontuação
			WHEN x"35" =>
					PONT := ((conv_integer(PONTUACAO) / 100) MOD 10) + 48;
			
					vga_char(15 downto 12) <= "0000";
					vga_char(7 downto 0) <= conv_std_logic_vector(PONT,8);
					vga_pos(15 downto 0)	<= conv_std_logic_vector(68, 16);	
					
					videoflag <= '1';
					PONTUACAOA <= PONTUACAO;
					VIDEOE <= x"DF";
					PROXESTADO <= x"37";

			-- Imprime o quarto dígito da pontuação
			WHEN x"37" =>
					PONT := ((conv_integer(PONTUACAO) / 1000) MOD 10) + 48;
					
					vga_char(15 downto 12) <= "0000";
					vga_char(7 downto 0) <= conv_std_logic_vector(PONT,8);
					vga_pos(15 downto 0)	<= conv_std_logic_vector(67, 16);	
					
					videoflag <= '1';
					PONTUACAOA <= PONTUACAO;
					VIDEOE <= x"DF";
					PROXESTADO <= x"39";
			
			-- Imprime o quinto dígito da pontuação
			WHEN x"39" =>
					PONT := ((conv_integer(PONTUACAO) / 10000) MOD 10) + 48;
					
					vga_char(15 downto 12) <= "0000";
					vga_char(7 downto 0) <= conv_std_logic_vector(PONT,8);
					vga_pos(15 downto 0)	<= conv_std_logic_vector(66, 16);	
					
					videoflag <= '1';
					PONTUACAOA <= PONTUACAO;
					
					VIDEOE <= x"DF";
					PROXESTADO <= x"00";
					
			-- Apaga B1
			WHEN x"00" =>			
				IF(BLOCO1 = BLOCO1A) THEN
					VIDEOE <= x"00";
				ELSIF(POUSOU_FLAG = '1') THEN
					VIDEOE <= x"08";
				ELSE
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					vga_pos(15 downto 0)	<= BLOCO1A;
						
					videoflag <= '1';
					VIDEOE <= x"DF";
					PROXESTADO <= x"02";
				END IF;
				
			-- Apaga B2
			WHEN x"02" =>
				vga_pos(15 downto 0)	<= BLOCO2A;
				videoflag <= '1';
				VIDEOE <= x"DF";
				PROXESTADO <= x"04";
			
			-- Apaga B3
			WHEN x"04" => 			
				vga_pos(15 downto 0)	<= BLOCO3A;
				videoflag <= '1';
				VIDEOE <= x"DF";
				PROXESTADO <= x"06";

			-- Apaga B4
			WHEN x"06" => 			
				vga_pos(15 downto 0)	<= BLOCO4A;
				videoflag <= '1';
				VIDEOE <= x"DF";
				PROXESTADO <= x"08";

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
				VIDEOE <= x"DF";
				PROXESTADO <= x"0A";

			-- Desenha B2
			WHEN x"0A" =>
				vga_pos(15 downto 0)	<= BLOCO2;
				BLOCO2A <= BLOCO2;
				videoflag <= '1';
				VIDEOE <= x"DF";
				PROXESTADO <= x"0C";
				
			-- Desenha B3
			WHEN x"0C" =>
				vga_pos(15 downto 0)	<= BLOCO3;
				BLOCO3A <= BLOCO3;
				videoflag <= '1';
				VIDEOE <= x"DF";
				PROXESTADO <= x"BB";
			
			-- Desenha B4	
			WHEN x"BB" =>
				vga_pos(15 downto 0)	<= BLOCO4;
				BLOCO4A <= BLOCO4;
				videoflag <= '1';
				VIDEOE <= x"DF";
				PROXESTADO <= x"0E";
				
				--Calcula a posição no vetor reduzido
				B1_POS := ((conv_integer(BLOCO1) - 135)/40) * 10 + ((conv_integer(BLOCO1) - 15 ) MOD 40);
				B2_POS := ((conv_integer(BLOCO2) - 135)/40) * 10 + ((conv_integer(BLOCO2) - 15 ) MOD 40);
				B3_POS := ((conv_integer(BLOCO3) - 135)/40) * 10 + ((conv_integer(BLOCO3) - 15 ) MOD 40);
				B4_POS := ((conv_integer(BLOCO4) - 135)/40) * 10 + ((conv_integer(BLOCO4) - 15 ) MOD 40);
			
			--Verifica se o bloco já pousou
			WHEN x"0E" =>
				VIDEOE <= x"DF";
				PROXESTADO <= x"31";
				IF(NOT(BLOCO1 < 1039 and BLOCO2 < 1039 and BLOCO3 < 1039 and BLOCO4 < 1039 AND MAPA(B1_POS + 10) = x"0" AND MAPA(B2_POS + 10) = x"0" AND MAPA(B3_POS + 10) = x"0" AND MAPA(B4_POS + 10) = x"0")) THEN
						MAPA(B1_POS) <= BLOCOCOR;
						MAPA(B2_POS) <= BLOCOCOR;
						MAPA(B3_POS) <= BLOCOCOR;
						MAPA(B4_POS) <= BLOCOCOR;
						POUSOU_FLAG <= '1';
						
						VIDEOE <= x"A0";
						
   					IF(BLOCO1 < 175 or BLOCO2 < 175 or BLOCO3 < 175 or BLOCO4 < 175) THEN
							FLAG_GO := '1';
							VIDEOE <= x"A9";
						END IF;
					
				END IF;
				
				B1_POS := (B1_POS/10) * 10;
				B2_POS := (B2_POS/10) * 10;
				B3_POS := (B3_POS/10) * 10;
				B4_POS := (B4_POS/10) * 10;
			
			WHEN x"0F" =>
				videoflag <= '0';
				VIDEOE <= x"31";
				
			--Verifica se a linha de b1 está completa
			WHEN x"A0" =>
				--Se todas as posições da linha de B1 estiverem ocupadas
				IF(NOT(MAPA(B1_POS + 1) = x"0") AND NOT(MAPA(B1_POS + 2) = x"0") AND NOT(MAPA(B1_POS + 3) = x"0") AND NOT(MAPA(B1_POS + 4) = x"0") AND NOT(MAPA(B1_POS + 5) = x"0") AND NOT(MAPA(B1_POS + 6) = x"0") AND NOT(MAPA(B1_POS + 7) = x"0") AND NOT(MAPA(B1_POS + 8) = x"0") AND NOT(MAPA(B1_POS + 9) = x"0") AND NOT(MAPA(B1_POS) = x"0")) THEN
						FLAG_B1 := '1';
				END IF;
				--Se todas as posições da linha de B2 estiverem ocupadas
				IF(NOT(B2_POS = B1_POS) AND NOT(MAPA(B2_POS + 1) = x"0") AND NOT(MAPA(B2_POS + 2) = x"0") AND NOT(MAPA(B2_POS + 3) = x"0") AND NOT(MAPA(B2_POS + 4) = x"0") AND NOT(MAPA(B2_POS + 5) = x"0") AND NOT(MAPA(B2_POS + 6) = x"0") AND NOT(MAPA(B2_POS + 7) = x"0") AND NOT(MAPA(B2_POS + 8) = x"0") AND NOT(MAPA(B2_POS + 9) = x"0") AND NOT(MAPA(B2_POS) = x"0")) THEN
						FLAG_B2 := '1';
				END IF;
				--Se todas as posições da linha de B3 estiverem ocupadas
				IF(NOT(B3_POS = B1_POS) AND NOT(B3_POS = B2_POS) AND NOT(MAPA(B3_POS + 1) = x"0") AND NOT(MAPA(B3_POS + 2) = x"0") AND NOT(MAPA(B3_POS + 3) = x"0") AND NOT(MAPA(B3_POS + 4) = x"0") AND NOT(MAPA(B3_POS + 5) = x"0") AND NOT(MAPA(B3_POS + 6) = x"0") AND NOT(MAPA(B3_POS + 7) = x"0") AND NOT(MAPA(B3_POS + 8) = x"0") AND NOT(MAPA(B3_POS + 9) = x"0") AND NOT(MAPA(B3_POS) = x"0")) THEN
						FLAG_B3 := '1';
				END IF;
				--Se todas as posições da linha de B4 estiverem ocupadas
				IF(NOT(B4_POS = B1_POS) AND NOT(B4_POS = B2_POS) AND NOT(B4_POS = B3_POS) AND NOT(MAPA(B4_POS + 1) = x"0") AND NOT(MAPA(B4_POS + 2) = x"0") AND NOT(MAPA(B4_POS + 3) = x"0") AND NOT(MAPA(B4_POS + 4) = x"0") AND NOT(MAPA(B4_POS + 5) = x"0") AND NOT(MAPA(B4_POS + 6) = x"0") AND NOT(MAPA(B4_POS + 7) = x"0") AND NOT(MAPA(B4_POS + 8) = x"0") AND NOT(MAPA(B4_POS + 9) = x"0") AND NOT(MAPA(B4_POS) = x"0")) THEN
						FLAG_B4 := '1';
				END IF;
				
				--Seta a posição para o final da linha
				B1_POS := B1_POS + 9;
				B2_POS := B2_POS + 9;
				B3_POS := B3_POS + 9;
				B4_POS := B4_POS + 9;
				VIDEOE <= x"A4";
			
			--Shifta todos os blocos para baixo
			WHEN x"A4" =>
				IF(B1_POS < 10 OR FLAG_B1 = '0') THEN
				
					IF (FLAG_B1 = '1') THEN 
						PONTUACAO <= PONTUACAO + x"0A";
					END IF;
					
					VIDEOE <= x"A5";
				ELSE
					MAPA(B1_POS) <= MAPA(B1_POS - 10);
					B1_POS := B1_POS - 1;
				END IF;
			--Shifta todos os blocos para baixo
			WHEN x"A5" =>
				IF(B2_POS < 10 OR FLAG_B2 = '0') THEN
				
					IF (FLAG_B2 = '1') THEN 
						PONTUACAO <= PONTUACAO + x"0A";
					END IF;
					
					VIDEOE <= x"A6";
				ELSE
					MAPA(B2_POS) <= MAPA(B2_POS - 10);
					B2_POS := B2_POS - 1;
				END IF;
			--Shifta todos os blocos para baixo
			WHEN x"A6" =>
				IF(B3_POS < 10 OR FLAG_B3 = '0') THEN
				
					IF (FLAG_B3 = '1') THEN 
						PONTUACAO <= PONTUACAO + x"0A";
					END IF;
					
					VIDEOE <= x"A7";
				ELSE
					MAPA(B3_POS) <= MAPA(B3_POS - 10);
					B3_POS := B3_POS - 1;
				END IF;
				
			--Shifta todos os blocos para baixo
			WHEN x"A7" =>
				IF(B4_POS < 10 OR FLAG_B4 = '0') THEN
				
					IF (FLAG_B4 = '1') THEN 
						PONTUACAO <= PONTUACAO + x"0A";
					END IF;
					
					VIDEOE <= x"FA";
				ELSE
					MAPA(B4_POS) <= MAPA(B4_POS - 10);
					B4_POS := B4_POS - 1;
				END IF;
				
			WHEN x"FA" =>
				IF(FLAG_B1 = '1' OR FLAG_B2 = '1' OR FLAG_B3 = '1' OR FLAG_B4 = '1') THEN
					VIDEOE <= x"A9";
					FLAG_B1 := '0';
					FLAG_B2 := '0';
					FLAG_B3 := '0';
					FLAG_B4 := '0';
				ELSE
					VIDEOE <= x"0F";
				END IF;
			--Redesenha a Tela
			WHEN x"A8" =>
				IF(COLUNAS = 24)THEN
					COLUNAS := 0;
					
					--Se não for GAME OVER
					IF(FLAG_GO = '0') THEN	
						VIDEOE <= x"0F";
					ELSE
						FLAG_GO := '0';
						VIDEOE <= x"F5";
					END IF;
					
					--Reseta a posição inicial para apagar
					APAGA_POS <= x"0087";
					videoflag <= '0';
				ELSE	
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= APAGACOR;
					vga_char(7 downto 0) <= BLOCOCHAR;
					vga_pos(15 downto 0)	<= APAGA_POS;
					
					--Incrementa a posicao
					APAGA_POS <= APAGA_POS + x"01";
					videoflag <= '1';
					VIDEOE <= x"A9";
				END IF;
			
			WHEN x"A9" =>
				--Caso tenha ultrapassado o limite direito
				IF(conv_integer(APAGA_POS) MOD 40 >= 25) THEN
					APAGA_POS <= APAGA_POS + x"1E";
					COLUNAS := COLUNAS + 1;
				END IF;
				videoflag <= '0';
				VIDEOE <= x"AA";
			
			WHEN x"AA" =>
				--Calcula a posição no vetor reduzido
				APAGAR_POS := ((conv_integer(APAGA_POS) - 135)/40) * 10 + ((conv_integer(APAGA_POS) - 15) MOD 40);
				VIDEOE <= x"AB";
			
			WHEN x"AB" =>
				--Se estiver vazia a posição, ou for GAMEOVER, imprima preto
				IF(NOT(MAPA(APAGAR_POS) = x"0") and NOT(FLAG_GO = '1')) THEN
					APAGACOR <= MAPA(APAGAR_POS);	
				ELSE
					APAGACOR <= x"0";	
				END IF;
				VIDEOE <= x"A8";
				
			--Desenha (G)AMEOVER
			WHEN x"F5" =>
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "1111";
					vga_char(7 downto 0) <= x"67";
					vga_pos(15 downto 0)	<= x"01CA";
					videoflag <= '1';
					PROXESTADO <= x"D2";
					VIDEOE <= x"DF";
			
			--Desenha G(A)MEOVER
			WHEN x"D2" =>
					vga_char(7 downto 0) <= x"61";
					vga_pos(15 downto 0)	<= x"01CB";
					videoflag <= '1';
					PROXESTADO <= x"D4";
					VIDEOE <= x"DF";
			
			--Desenha GA(M)EOVER
			WHEN x"D4" =>
					vga_char(7 downto 0) <= x"6D";
					vga_pos(15 downto 0)	<= x"01CC";
					videoflag <= '1';
					PROXESTADO <= x"D6";
					VIDEOE <= x"DF";
					
			--Desenha GAM(E)OVER
			WHEN x"D6" =>
					vga_char(7 downto 0) <= x"65";
					vga_pos(15 downto 0)	<= x"01CD";
					videoflag <= '1';
					PROXESTADO <= x"D8";
					VIDEOE <= x"DF";
			
			--Desenha GAME(O)VER
			WHEN x"D8" =>
					vga_char(7 downto 0) <= x"6F";
					vga_pos(15 downto 0)	<= x"01F2";
					videoflag <= '1';
					PROXESTADO <= x"DA";
					VIDEOE <= x"DF";
					
			--Desenha GAMEO(V)ER
			WHEN x"DA" =>
					vga_char(7 downto 0) <= x"76";
					vga_pos(15 downto 0)	<= x"01F3";
					videoflag <= '1';
					PROXESTADO <= x"DC";
					VIDEOE <= x"DF";
			
			--Desenha GAMEOV(E)R
			WHEN x"DC" =>
					vga_char(7 downto 0) <= x"65";
					vga_pos(15 downto 0)	<= x"01F4";
					videoflag <= '1';
					PROXESTADO <= x"DE";
					VIDEOE <= x"DF";
					
			--Desenha GAMEOVE(R)	
			WHEN x"DE" =>
					vga_char(7 downto 0) <= x"72";
					vga_pos(15 downto 0)	<= x"01F5";
					videoflag <= '1';
					PROXESTADO <= x"DF";
					VIDEOE <= x"DF";

			WHEN x"DF" =>
				VIDEOE <= PROXESTADO;
				videoflag <= '0';
			WHEN OTHERS =>
		END CASE;S
	END IF;
END PROCESS;

END a;