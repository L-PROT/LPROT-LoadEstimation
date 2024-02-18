% Fun��o que, a partir do objeto DSSCirc, do OpenDSS e da lista com o nome
% das barras (nos), obt�m o vetor das correntes injetadas e das tens�es
% nodais e os ordena a partir da fun��o 'sortrows'. Al�m disso, a fun��o
% utiliza a matriz de admit�ncias nodais para comparar o vetor de correntes
% injetadas nos n�s fornecido pelo objeto DSSCirc com o vetor obtido a
% partir da multiplica��o Y*V, na qual os dois par�metros s�o obtidos pelo
% objeto DSSCirc. A fun��o entrega dois arrays de c�lulas com os valores de
% tens�o e corrente obtidos pelas duas formas (diretamente pelo OpenDSS ou
% calculados a partir de I = Y*V ou V = Y\I) e calcula o erro entre essas
% formas. Esse erro confere se a ordem dos n�s est� corretamente definida e
% se existe algum erro na formula��o da matriz Y. Os argumentos de entrada
% s�o:
% DSSCirc - Objeto DSSCircuit do OpenDSS ap�s o resultado de cada simula��o
% nos - lista com a nomenclatura dos n�s sem ordena��o pr�via
% Ysis_list - lista com a matriz de admit�ncia do sistema, ordenada
% previamente e indicando a nomenclatura de cada n�
% choice - caso 1, utiliza a ordena��o dos n�s agrupada por �rea de medi��o

function [Vordem Iordem] = monta_V_e_I(DSSCirc,...
                                       nos,...
                                       Ysis_list,...
                                       choice)

% -------------------------------------------------------------------------
% a) Aquisi��o e ordena��o da matriz V
% -------------------------------------------------------------------------
% a.1) Montagem como lista, para facilitar debug
% -------------------------------------------------------------------------
V = DSSCirc.YNodeVarray;
Vpu = num2cell(DSSCirc.AllBusVmagPu');
aux = size(V,2)/2;
cell_aux = reshape(V,[2,aux]);
cell_aux = cell_aux';
Xreal = V(1:2:end);
Ximag = V(2:2:end);
V = complex(Xreal',Ximag');
V = num2cell(V);
if(choice==1)
    V = [nos(:,3) V];
    Vpu = [nos(:,4) Vpu];
else
    V = [nos(:,1) V];
    Vpu = [nos(:,2) Vpu];
end

% -------------------------------------------------------------------------
% a.2) Ordena��o das linhas e colunas (ordem crescente dos n�s)
% -------------------------------------------------------------------------
Vordem_aux = [sortrows(V,1),sortrows(Vpu,1)];
Vordem = Vordem_aux(:,[1,2,4]);

% -------------------------------------------------------------------------
% b) Aquisi��o e ordena��o da matriz I
% -------------------------------------------------------------------------
% b.1) Montagem
% -------------------------------------------------------------------------
I = DSSCirc.YCurrents;
aux = size(I,2)/2;
cell_aux = reshape(I,[2,aux]);
cell_aux = cell_aux';
Xreal = I(1:2:end);
Ximag = I(2:2:end);
I = complex(Xreal',Ximag');
I = num2cell(I);
if(choice==1)
    I = [nos(:,3) I];
else
    I = [nos(:,1) I];
end

% -------------------------------------------------------------------------
% b.2) Ordena��o das linhas e colunas (ordem crescente dos n�s)
% -------------------------------------------------------------------------
Iordem = sortrows(I,1);

% -------------------------------------------------------------------------
% c) Dado que o vetor de correntes medidas tem diferencas do vetor
% obtido pela multiplicacao de Ysistema por Vordem, e importante obter um
% vetor de tensoes nodais alternativo [Valt], de modo que [I] =
% [Y]*[Valt]. Da mesma forma, � importante obter [Ialt] de modo que [V] =
% [Y]^{-1}*[Ialt]. Para fins de debug.
% -------------------------------------------------------------------------
aux = Iordem(:,2);
aux = cell2mat(aux);
cell_aux = Ysis_list(2:end,2:end);
cell_aux = cell2mat(cell_aux);
aux2 = Vordem(:,2);
aux2 = cell2mat(aux2);
Valt = cell_aux\aux;
Ialt = cell_aux * aux2;

% -------------------------------------------------------------------------
% d) Obter a diferen�a entre [V] e [Valt] e entre [I] e [Ialt] de modo a
% ser um �ndice de confian�a para debug da modelagem do sistema. Colocar
% esses valores nos vetores de sa�da em forma de lista para que o debug
% fique dispon�vel no algoritmo principal (gera_dados.m).
% -------------------------------------------------------------------------

aux = Ialt - aux;
aux = abs(aux);
aux2 = Valt - aux2;
aux2 = abs(aux2);
aux = num2cell(aux);
aux2 = num2cell(aux2);
Valt = num2cell(Valt);
Ialt = num2cell(Ialt);
Iordem = [Iordem Ialt aux];
Vordem = [Vordem Valt aux2];
aux = {'No','Imed','Ysistema*Vmed','Delta'};
Iordem = [aux; Iordem];
aux = {'No','Vmed','Vpu','Ysistema\Imed','Delta'};
Vordem = [aux; Vordem];