% A fun��o organizebus tem o prop�sito de modificar a nomenclatura das barras
% nativa do OpenDSS de modo a:
% 1 - permitir identifica��o de modo simples do alimentador, dos pontos de 
% medi��o de corrente, de tens�o e do subsistema ao qual a barra faz parte 
% (no caso de �reas de medi��o)
% 2 - permitir que as barras possam ser ordenadas, a partir do comando 
% sortrows, de modo que as barras do gerador fiquem nas primeiras posi��es 
% e as barras de medi��o de tens�o fiquem logo em seguida
% 3 - quando houver mais de uma �rea de medi��o, as barras devem ser 
% ordenadas, a partir do comando sortrows, de modo que as barras da �rea 
% de medi��o 1 fiquem nos primeiros lugares, seguidas pelas barras da �rea 
% de medi��o 2 e assim por diante
% 4 - dentro de cada �rea de medi��o, as barras devem ser ordenadas de acordo
% com o �tem 2, sendo o gerador substitu�do pela medi��o principal, que d�
% origem a �rea de medi��o em quest�o
% Para isso, a estrutura geral de nomenclatura das listas ser� adotada
% da seguinte forma: (SS)_(MA/MT)_(Barra).(Fase) ou (SS)_(Barra).(Fase), 
% aonde:
% SS = Subsistema, indica a �rea de medi��o na qual se encontra a barra.
% Caso o sistema n�o for dividido em �reas de medi��o, SS ser� igual a 01
% para todas as barras. A correspond�ncia entre cada barra e sua �rea de
% medi��o � feita a partir da matriz de incid�ncia da rede e do fato dela
% ser radial.
% MA/MT = Marca��o de alimentador/Marca��o de medi��o de tens�o, indica se
% a barra pertence ao alimentador do sistema/�rea de medi��o ou se a barra
% possui medi��o de tens�o. 
% 1 - Se for barra de alimentador/gerador MA/MT = '***'.
% 2 - Se for barra com medi��o de tens�o apenas, MA/MT = '*_(tag_ordem)'
% Ps: (tag_ordem) � um n�mero de dois d�gitos para ordenar as
% barras conforme ordena��o da lista medVODSS.
% 3 - Se for barra com medi��o de tens�o e houver elemento com medi��o de
% corrente tal que a corrente incide naquela barra, este poder� ser um
% ponto de divis�o do circuito em �reas de medi��o. Nesse caso.
% MA/MT = '**_(tag_ordem)'.
% Ps: (tag_ordem) � um n�mero de dois d�gitos para ordenar as
% barras conforme ordena��o na lista medVODSS.
% 4- Caso a barra n�o for nem de alimenta��o e nem contiver medi��o de 
% tens�o esse marcador ser� ausente na nomenclatura,  MA/MT = '', a
% nomenclatura da barra ser� do tipo SS)_(Barra).(Fase).
% (Barra) - identificador da barra, como fornecido pelo OpenDSS, corrigido
% por um sistema de nomenclatura descrito em organizeNames.m
% (Fase) - 1 e/ou 2 e/ou 3, dependendo da fase do barramento que ser�
% utilizada. Quando mais de uma fase � utilizada, as fases s�o separadas
% por pontos (ex: 00670.1.2 refere-se as fases 1 e 2 da barra 00670).
function [f root_nodes subrede_parents] =  organizebus(barraV,...% Barras com medi��o de tens�o
                                                       DSSCirc,... % Elemento DSSCircuit gerado pela interface COM
                                                       DSSElem,... % Elemento DSSCircuit gerado pela interface COM
                                                       DSSSol,...  % Elemento DSSCircuit gerado pela interface COM
                                                       divpoint)   % Pontos de divis�o do sistema em �reas de medi��o
% -------------------------------------------------------------------------
% a) Obt�m lista com todas as barras do circuito e organiza a nomenclatura
% -------------------------------------------------------------------------
nodesODSS = [DSSCirc.YNodeOrder,DSSCirc.AllNodeNames];
% fun��o para padronizar a nomenclatura dos n�s para qqr circuito
nodes = organizeNames(nodesODSS); 
% -------------------------------------------------------------------------
% b.1) Recebe lista com n�s da matriz de incid�ncia, j� aplicando a
% nomenclatura padronizada
% -------------------------------------------------------------------------
incColODSS = DSSSol.IncMatrixCols; % recebe lista de n�s da M.Inc.
incCol = organizeNames(incColODSS); % aplica nomenclatura padronizada
% -------------------------------------------------------------------------
% b.2) Recebe lista com n�s de outra vari�vel do OpenDSS e aplica a
% nomenclatura padronizada. Isso foi necess�rio porque a ordem das barras
% entre essas vari�veis se alterava na vers�o do OpenDSS utilizada.
% Essa lista de barras ser� utilizada nas fun��es extras (t�pico h)
% -------------------------------------------------------------------------
BusNamesODSS = DSSCirc.AllBusNames; % recebe lista de barras de terceira fonte
BusNames = organizeNames(BusNamesODSS); % aplica nomenclatura padronizada
% -------------------------------------------------------------------------
% c) Obt�m os n�s referentes � fonte de tens�o e aplica a nomenclatura
% padr�o
% -------------------------------------------------------------------------
DSSCirc.SetActiveElement(['VSOURCE.SOURCE']);
fontenos = organizeNames(DSSElem.BusNames(1)); % aplica nomenclatura correta
% -------------------------------------------------------------------------
% d) Renomeia os n�s da fonte e dos pontos de medi��o
% -------------------------------------------------------------------------
% d.1) Renomeia os n�s da fonte acrescentando a string ***_ antes do nome
% -------------------------------------------------------------------------
nodes = regexprep(nodes,fontenos{1},['***_' fontenos{1}]);
% -------------------------------------------------------------------------
% d.2) Renomeia os n�s de medi��o de tens�o acrescentando a string **_
% antes do nome caso for um ponto de divis�o do circuito (for um ponto ao
% qual a medi��o de corrente tamb�m se aplica) ou acrescentando a string *_
% caso n�o for um ponto de divis�o do circuito.
% Ps: a fun��o lower coloca os caracteres do alfabeto em letra min�scula
% para facilitar a compara��o no-case-sensitive entre strings.
% -------------------------------------------------------------------------
medV = organizeNames(barraV);
aux2 = 0;
aux3 = 0;
for aux=1:size(medV,2)
    % procura os pontos da lista de medi��o na lista de pontos de divis�o 
    % do circuito
    index = strfind(lower(divpoint),lower(medV{aux}));
    index = find(~cellfun(@isempty,index));
    if(~isempty(index)) % caso encontrar, insere a marca��o MT/MA correspondente (**)
        aux2 = aux2 + 1;
        if(aux2<10)
            nodes = regexprep(nodes,medV{aux},['**_0' num2str(aux2) '_' medV{aux}]);
        else
            nodes = regexprep(nodes,medV{aux},['**_' num2str(aux2) '_' medV{aux}]);
        end
    else % caso n�o encontrar, insere a marca��o MT/MA correspondente (*)
        aux3 = aux3 + 1;
        if(aux<10)
            nodes = regexprep(nodes,medV{aux},['*_0' num2str(aux3) '_' medV{aux}]);
        else
            nodes = regexprep(nodes,medV{aux},['*_' num2str(aux3) '_' medV{aux}]);
        end
    end
end

% -------------------------------------------------------------------------
% d) Constr�i a matriz de incid�ncia IncList em forma de lista para
% determinar as barras de cada �rea de medi��o;
% Ps: A matriz de incid�ncia vem do OpenDSS na forma de vetor-linha, cada tr�s
% colunas representam um �nico elemento diferente de zero dessa matriz. A
% nota��o para cada elemento �: [linha coluna incid�ncia], onde "linha" e
% "coluna" s�o os n�meros da linha e da coluna na matriz e incid�ncia �
% a condi��o de incid�ncia entre o elemento correspondente � linha e a
% barra correspondente � coluna (-1 ou 1). Depois de todos os elementos n�o
% nulos, a matriz vem com um zero adicional que representa o fim da cadeia
% de caracteres num�ricos.
% -------------------------------------------------------------------------
IncTab = DSSSol.IncMatrix; % obt�m a matriz de incid�ncia do OpenDSS
IncTab = IncTab(1:(length(IncTab)-1)); % despreza o zero adicional
IncTab = reshape(IncTab,3,[])'; % reorganiza a matriz em 3 colunas
incLine = DSSSol.IncMatrixRows; % obt�m os elementos representados pelas linhas de IncList
lines = size(incLine,1);
colum = size(incCol,1);
IncMatrix = zeros(lines,colum); % esqueleto da matriz de incid�ncia
for aux2=1:size(IncTab,1)
    IncMatrix(IncTab(aux2,1)+1,IncTab(aux2,2)+1)=IncTab(aux2,3); % preenche as posi��es da matriz
end
IncList = [ '#' incCol'; incLine num2cell(IncMatrix)]; % armazena a matriz e os nomes como uma lista

% -------------------------------------------------------------------------
% e) Determina a barra do alimentador (raiz) em IncList
% -------------------------------------------------------------------------
for aux=2:size(IncList,2)
    index=find(IncMatrix(:,aux-1)==-1); % procura por -1 em cada coluna
    if(isempty(index))  % barra do alimentador � a �nica barra cuja coluna n�o contem -1
        root_node = IncList(1,aux);
    end
end

% -------------------------------------------------------------------------
% f) A partir dos pontos de divis�o do circuito, dado pela lista divpoint,
% divide a lista de barras incCol em listas de barras por �rea de medi��o
% e armazena essas listas no list array subrede_parents
% -------------------------------------------------------------------------
root_nodes = [root_node divpoint]; % lista com as barras raiz em cada subrede
list_connections = {};
for aux=1:size(root_nodes,2) % Percorre todas as barras em root nodes
    list_parents = root_nodes(aux); % list_parents armazena cada subrede temporariamente, a primeira barra � a que est� em root_nodes
    for aux2=1:size(IncMatrix,2) % aux2 percorre, no m�ximo, as barras nas colunas de IncMatrix (na horizontal)
        if(aux2<=size(list_parents,1)) % por�m, aux2 n�o pode passar o tamanho da subrede
            father = list_parents{aux2}; % toma uma barra como barra-pai
            index = strfind(lower(root_nodes),lower(father)); % verifica se a barra-pai est� em root_nodes
            index = find(~cellfun(@isempty,index)); % e descobre nesta linha, caso estiver nada � feito e a pr�xima barra em list_parents � selecionada
            if(isempty(index) || aux2 == 1) % caso n�o for raiz ou caso seja raiz, mas seja a barra do alimentador principal (aux2=1)
                index = strfind(lower(IncList(1,:)),lower(father)); % procura a coluna da barra pai em incList
                index = find(~cellfun(@isempty,index)); % descobre a coluna da barra pai em IncList
                sun_lines = find(IncMatrix(:,index-1)==1); % sun_lines s�o as linhas dos elementos que saem da barra pai
                if(~isempty(sun_lines)) % caso houverem linhas que saem da barra-pai
                    for aux3 = 1:size(sun_lines,1) % aux3 percorre todos os elementos em cada sun_line
                        sun_colum = find(IncMatrix(sun_lines(aux3),:)==-1); % procura a barra aonde esses elementos chegam (-1)
                        for aux4=1:size(sun_colum)
                            sun = IncList{1,sun_colum(aux4)+1};   % a coluna aonde os elementos incidem revela as barras filho
                            index = strfind(lower(list_parents),lower(sun)); % verifica se a barra filho j� consta na lista da subrede
                            index = find(~cellfun(@isempty,index)); % caso constar, descobre a posi��o em que consta
                            if(isempty(index)) % caso n�o constar, a barra ser� adicionada a subrede
                                list_parents = [list_parents; sun];
                                list_connections = [list_connections; {father, sun}];
                            end
                        end
                    end
                end
            end
        end
    end % O loop s� � abandonado se chegar em uma barra raiz de outra subrede
    subrede_parents{1,aux}=list_parents; % subrede_parents � lista com todas as subredes e conex�es.
    subrede_parents{2,aux}=list_connections;
    list_parents={}; % esvazia list_parents para guardar a pr�xima subrede
end
% Obs: note que as barras de divis�o em �reas de medi��o fazem parte de
% duas subredes, estar�o em duas listas
% -------------------------------------------------------------------------
% g) Cria uma lista de barras e fases, nos moldes de nodes, por�m dividindo
% a lista por �reas de medi��o
% -------------------------------------------------------------------------
% g.1) Utiliza a vari�vel list_parents para criar uma lista de barras com
% separa��o por �rea de medi��o
% -------------------------------------------------------------------------
for aux = 1:size(subrede_parents,2)
    list_parents = [list_parents; subrede_parents{1,aux}];
end
% -------------------------------------------------------------------------
% g.2) Constr�i uma terceira coluna na vari�vel nodes similar a primeira,
% por�m marcando as barras com as respectivas �reas de medi��o. Utiliza-se,
% para isso, da vari�vel subrede_parents
% As barras de divis�o estar�o em duas subredes, por�m o algoritmo vai
% coloc�-las nas subredes com �ndice maior
% -------------------------------------------------------------------------
nodes(1:end,3)=cell(size(nodes,1),1);
for aux = 1:size(subrede_parents,2) % percorre todas as listas de barras de subrede
    for aux2 = 1:size(subrede_parents{1,aux},1) % em cada subrede, percorre todas as barras
        index=strfind(lower(nodes(:,1)),lower(subrede_parents{1,aux}{aux2,1})); % procura cada n� em cada subrede na lista de n�s do circuito geral
        index = find(~cellfun(@isempty,index)); % encontra as posi��es dessas barras na lista de n�s do circuito geral
        for aux3=1:size(index,1) % percorre todas as posi��es em que a barra da subrede foi encontrada
            nodes{index(aux3,1),3} = ['0' num2str(aux) '_' nodes{index(aux3,1),1}]; % coloca o prefixo da subrede no nome e guarda na coluna 3 de nodes
        end
    end
end
% -------------------------------------------------------------------------
% g.2) Constr�i uma quarta coluna na vari�vel nodes similar a segunda, por�m
% marcando as barras com as respectivas �reas de medi��o
% -------------------------------------------------------------------------  
nodes(1:end,4)=cell(size(nodes,1),1);
for aux = 1:size(subrede_parents,2)
    for aux2 = 1:size(subrede_parents{1,aux},1)
        index=strfind(lower(nodes(:,2)),lower(subrede_parents{1,aux}{aux2,1}));
        index = find(~cellfun(@isempty,index));
%         if(isempty(index))
%             index=strfind(nodes(:,2),upper(subrede_parents{1,aux}{aux2,1}));
%             index = find(~cellfun(@isempty,index));
%         end
        for aux3=1:size(index,1)
            nodes{index(aux3,1),4} = ['0' num2str(aux) '_' nodes{index(aux3,1),2}];
        end
    end
end

% -------------------------------------------------------------------------
% h) Extra: N�vel das barras e dist�ncia do alimentador
% -------------------------------------------------------------------------  
% h.1) Relaciona cada barra � sua dist�ncia do alimentador
% -------------------------------------------------------------------------  
BLevels = DSSSol.BusLevels;
% creates a table with the data
myBLTable = [];
for i = 1:size(BusNames),
    myBLTable = [myBLTable; [BusNames(i,1),num2str(BLevels(1,i))]];
end;
myBLTable = sortrows(myBLTable,2);

% -------------------------------------------------------------------------
% h.2) Acrescenta a informa��o de dist�ncia de cada barra da primeira
% coluna ao alimentador em nodes, construindo uma quinta coluna
% -------------------------------------------------------------------------  
nodes(1:end,5)=cell(size(nodes,1),1);
for aux = 1:size(BusNames,1)
    index=strfind(lower(nodes(:,1)),lower(BusNames{aux,1}));
    index = find(~cellfun(@isempty,index));
%     if(isempty(index))
%         index=strfind(nodes(:,1),upper(BusNames{aux,1}));
%         index = find(~cellfun(@isempty,index)); 
%     end
    for aux2=1:size(index,1)
        nodes(index(aux2,1),5) = myBLTable(aux,2);
    end
end
% -------------------------------------------------------------------------
% h.3) Acrescenta a informa��o de dist�ncia de cada barra da segunda
% coluna ao alimentador em nodes, construindo uma sexta coluna
% ------------------------------------------------------------------------- 
nodes(1:end,6)=cell(size(nodes,1),1);
for aux = 1:size(BusNames,1)
    index=strfind(lower(nodes(:,2)),lower(BusNames{aux,1}));
    index = find(~cellfun(@isempty,index));
%     if(isempty(index))
%         index=strfind(nodes(:,2),upper(BusNames{aux,1}));
%         index = find(~cellfun(@isempty,index)); 
%     end
    for aux2=1:size(index,1)
        nodes(index(aux2,1),6) = myBLTable(aux,2);
    end
end

f = nodes;
% As sa�das da fun��o s�o:
% f - lista de barras como indicado no cabe�alho. Possui 6 colunas, as
% colunas 1, 3 e 5 se baseiam no vetor DSSCircuit.YNodeOrder enquando a 2,
% 4 e 6 se baseiam no vetor DSSCircuit.AllNodeNames. A quinta e sexta
% coluna s�o uma fun��o experimental do OpenDSS, que calculam a dist�ncia
% entre a barra e o alimentador.
% root_nodes - lista com barras raiz de cada uma das subredes. Se o
% circuito n�o estiver dividido em �reas de medi��o, essa lista vai conter
% apenas a barra do alimentador principal
% subredes - lista com barras em cada uma das subredes definidas pelos
% pontos de medi��o de tens�o e corrente. Se n�o houver divis�o do circuito
% em �reas de medi��o, essa lista visa conter apenas a rede principal.