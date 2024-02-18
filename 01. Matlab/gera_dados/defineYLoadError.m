% Fun��o que obt�m a matriz de admit�ncia das cargas do sistema de duas
% formas, compara as duas e obt�m o erro de 4 formas poss�veis considerando
% a pot�ncia real com a calculada segundo estima��o.
% Os argumentos da fun��o s�o:
% Ysis_list - Matriz de admit�ncia do sistema com as cargas, no formato de
% c�lula ou lista;
% Ynet_list - Matriz de admit�ncia do sistema sem as cargas, no formato de
% c�lula ou lista;
% Carga - Tabela de informa��es sobre as cargas, sa�da da fun��o defineLoad;
% no_ordem - Lista com nomenclatura dos n�s devidamente ordenada a partir
% de 'sortrows'.
% verifica - soma das admit�ncias de todas as cargas fase-terra. Essa soma
% dever� ser a soma de todos os elementos da matriz de admit�ncias da carga
% do sistema. Tamb�m soma cargas trif�sicas em estrela.
function [Ycarga_list Erro] = defineYLoadError(Ysis_list,Ynet_list,Carga,...
                                          no_ordem,verifica)
% -------------------------------------------------------------------------
% a) Calculo da matriz de cargas - ja com os nos ordenados de forma
% crescente - de acordo com no_ordem_ascending
% -------------------------------------------------------------------------
Y1 = Ysis_list(2:end,2:end);
Y1 = cell2mat(Y1);
Y2 = Ynet_list(2:end,2:end);
Y2 = cell2mat(Y2);
Ycarga = Y1 - Y2;
Ycarga_list = num2cell(Ycarga);
Ycarga_list = ['#Y' no_ordem';no_ordem Ycarga_list];

% -------------------------------------------------------------------------
% b) Teste para ver se consegue-se construir Ycarga a partir dos dados da
% lista de cargas. Note que Ycarga � uma matriz s� com as cargas do
% circuito. Esse procedimento � diferente do adotado em opti_ybus, que
% busca construir a matriz do sistema a partir da matriz de rede sem as
% cargas. Esse busca reconstruir apenas a matriz de cargas (Yl - Y2) a
% partir de uma matriz nula e da tabela de cargas.
% -------------------------------------------------------------------------
% Yposition = Carga(2:end,8);
% Yl = zeros(size(Ynet_list,1)-1,size(Ynet_list,2)-1);
Ysol = Carga(2:end,10);
Ysol = cell2mat(Ysol);
Ysol = [real(Ysol),imag(Ysol)];
Yl = defineYLoad(Ysol,Y2,Carga(2:end,8));

% -------------------------------------------------------------------------
% c) C�lculo do Erro na montagem da matriz de cargas
% -------------------------------------------------------------------------
verifica2 = sum(sum(Ycarga));
verifica3 = sum(sum(Yl));
Ydiferenca = Ycarga - Yl;
Erro1 = max(max(abs(Ydiferenca)));
Erro2 = verifica - verifica2;
Erro3 = verifica - verifica3;
Erro4 = verifica2 - verifica3;
Erro = abs(max([Erro1 Erro2 Erro3 Erro4]));