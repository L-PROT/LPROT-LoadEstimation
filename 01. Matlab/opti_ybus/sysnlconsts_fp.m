% Fun��o de restri��o com rela��o as tens�es medidas. Esse arquivo cont�m
% todas as fun��es de restri��o n�o lineares poss�veis, enquanto o arquivo
% sysnlconsts.m cont�m apenas as que ser�o utilizadas pelo algoritmo.

function [c,ceq] =    sysnlconsts(x,         ... % Vetor de admit�ncia das cargas
                                 Vmed,       ... % Medicoes de tensao (tensao em todos os nos) - Complexo
                                 Imedlist,   ... % Medicao de corrente na subestacao e deriva��es
                                 Vp,         ... % Medicoes de tensao (tensao em todos os nos) - M�dulo em pu
                                 Inodes,     ... % Vetor de correntes nodais
                                 Ynet,       ... % Matriz de admitancia 41 x 41 da rede sem as cargas
                                 Yposition,  ... % C�lula com as posi��es de cada carga dentro de Ysys
                                 Yprimaria,  ... % Matrizes de admit. nodal da fonte e dos elementos com medi��o de I.
                                 nomeVmed,   ... % Lista com Barras de medi��o de tens�o.
                                 n1,         ... % Numero de medi��es de corrente
                                 n2,         ... % Numero de medi��es de tens�o, exceto no alimentador
                                 trafList,   ... % Lista com dados de transformadores
                                 dominio)        % 1 para dominio das admit�ncias e 2 para imped�ncias
% PS: O vetor solution contem potencias ativas na primeira coluna e
% reativas na segunda coluna, as cargas estao de acordo com a ordem
% crescente das nomenclaturas dos nos, assim como descrito na variavel
% Yload.
% -------------------------------------------------------------------------
% 0) Inicializa��o das vari�veis de restri��o
% -------------------------------------------------------------------------
c = [];
ceq = [];
FPmin = 0.5;
Vpumax = 1.05;
Vpumin = 0.93;
m = 3+n2;
sol = x';
dim = size(sol,1)/2;
sol = [sol(1:dim,1), sol(dim+1:end,1)];

% -------------------------------------------------------------------------
% 1) Restri��o para fator de pot�ncia m�nimo
% -------------------------------------------------------------------------
fp = -sol(:,1) + FPmin*sqrt(sol(:,1).^2 + sol(:,1).^2);
c = [c; fp];
    
