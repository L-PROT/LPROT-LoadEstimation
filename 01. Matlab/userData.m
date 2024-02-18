% DEFINI��O DE CONFIGURA��ES PRINCIPAIS DE SIMULA��O

% 1. CONFIGURA��ES DA VARI�VEL MAINSET:
% As versions representam formas de calcular o valor da fun��o de otimiza��o:
% 1 - Fun��o objetivo f = max(abs(delta)), sendo delta = I - h(y);
% 2 - Fun��o objetivo f = max(abs(delta)), sendo delta = V - h(y);
% 3 - Fun��o objetivo f = max([abs(Re(delta));abs(Imag(delta))]),sendo delta = I - h(y);
% 4 - Fun��o objetivo f = max([abs(Re(delta));abs(Imag(delta))]), sendo delta = V - h(y);
% 5 - Fun��o objetivo f = max(abs(delta)), sendo delta = (I - h(y))/I;
% 6 - Fun��o objetivo f = max(abs(delta)), sendo delta = (V - h(y))/V;
% 7 - Fun��o objetivo f = max([abs(Re(delta))./abs(Re(I));abs(Imag(delta))./abs(Imag(I))]), sendo delta = I - h(y);
% 8 - Fun��o objetivo f = max([abs(Re(delta))./abs(Re(V));abs(Imag(delta))./abs(Imag(V))]), sendo delta = V - h(y);
% 9 - Fun��o objetivo f = max(abs(real(delta))), sendo delta = I - h(y);
% 10 - Fun��o objetivo f = max(abs(real(delta))), sendo delta = V - h(y);
% 11 - Fun��o objetivo f = max(abs(imag(delta))), sendo delta = I - h(y);
% 12 - Fun��o objetivo f = max(abs(imag(delta))), sendo delta = V - h(y);
% 13 - Fun��o objetivo f = max(abs(real(delta))), sendo delta = (I - h(y))/I;
% 14 - Fun��o objetivo f = max(abs(real(delta))), sendo delta = (V - h(y))/V;
% 15 - Fun��o objetivo f = max(abs(imag(delta))), sendo delta = (I - h(y))/I;
% 16 - Fun��o objetivo f = max(abs(imag(delta))), sendo delta = (V - h(y))/V;
mainset.version = 1;
% * mainset.restriction - 0 para n�o utilizar restri��es n�o lineares, 1 caso contr�rio;
mainset.restriction = 0; 
% 1 para restri��o por fator de pot�ncia;
% 2 para restri��o por n�vel de tens�o nas barras;
% 3 para restri��o de carregamento dos transformadores;
% 4 para restri��o por medi��o de tens�o;
% 5 para restri��o por medi��o de corrente;

% 2. DEFINI��O DAS BARRAS COM MEDI��O DE TENS�O E CORRENTE

% IEEE13 BARRAS
%         barraVmed13 = {'670' '671' '632'}; % Barras do Tronco Principal
        barraVmed13 = {'670'}; % Divis�o em areas de medi�ao
%         barraVmed13 = {'634' '675'}; % Barras com piores estima��es
%         elemImed13 = {'632670' '670671' '650632'}; % Linhas do tronco principal com melhores resultados na tens�o
        elemImed13 = {'632670'}; % Divis�o em �reas de medi�ao
%         elemImed13 = {'632633' '692675'}; % Elementos com piores medi��es.
% PS: a barra 634 fica conectada a um transformador, por isso n�o
% tem como medir corrente, dado que o processo s� trabalha com
% medi��o em linhas. Por isso, foi escolhida a linha 632633 que faz
% parte do ramo que cont�m a carga 634.

% IEEE34 BARRAS
%         barraVmed34 = {'808' '816' '824' '854' '832' '858' '834' '836'};
%         elemImed34 = {'L1' 'L24' 'L9' 'L15' 'L25' 'L16' 'L29' 'L30'};

% IEEE37 BARRAS
%         barraVmed37 = {'701' '718'}; % Barras piores estimativas
%         barraVmed37 = {'702' '703' '709' '708' '734' '711'}; % Barras com deriva��es
        barraVmed37 = {'709'}; % Divis�o em areas de medi�ao
%         barraVmed37 = {'701' '702' '703' '730' '709' '708' '733' '734' '737' '738' '711' '741'}; % tronco principal
%         elemImed37 = {'L35' 'L23'}; % Linhas chegam nas barras com piores medi��es
%         elemImed37 = {'L1' 'L4' 'L27' 'L17' 'L28' 'L32'}; % Linhas chegam nas barras com deriva��es
        elemImed37 = {'L27'}; % Divis�o em areas de medi��o
%         elemImed37 = {'L35' 'L1' 'L4' 'L6' 'L27' 'L17' 'L14' 'L28' ...
%                     'L31' 'L29' 'L32' 'L20'}; % Linhas chegam nas barras do tronco principal
% IEEE123 BARRAS
%         barraVmed123 = {'1' '13' '15' ...
%                         '18' '35' '36' '40' '42' '44' '47' ...
%                         '21' '23' '25' '26' '27' ...
%                         '54' '57' '60' '67' '110' '108' '105' '101' ...
%                         '97' '72' '76' '78' '81' '87' '89' '91' '93' ...
%                         '95'}; % barras de deriva��o
%         barraVmed123 = {'13' ...
%                         '18' '35' ...
%                         '54' '97' '72'}; % principais deriva��es
        barraVmed123 = {'72'}; % divis�o em 2 �reas de medi�ao
%         elemImed123 =  {'L10' ...
%                         'L13' 'L114' 'L35' 'L36' 'L41' 'L43' 'L45'...
%                         'L19' 'L22' 'L24' 'L25' 'L27' ...
%                         'L53' 'L55' 'L58' 'L117' 'L109' 'L105' 'L101' 'L118' ...
%                         'L68' 'L67' 'L73' 'L78' 'L81' 'L86' 'L88' 'L90' 'L92' ...
%                         'L94'}; % linhas at� as barras de deriva��o
%         elemImed123 =  {'L115' 'L10' 'L34' ...
%                         'L13' 'L114' ...
%                         'L53' 'L68' 'L67'}; % linhas at� as principais deriva��es.
        elemImed123 =  {'L67'}; % divis�o em 2 �reas de medi��o