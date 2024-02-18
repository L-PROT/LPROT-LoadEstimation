% Verifica se existem pontos do circuito nos quais se medem tens�o e
% corrente, analisando os vetores barraV e elemI.
% Determina os pontos a partir dos quais o sistema radial pode ser dividido
% em �reas de medi��o, de modo a particionar a solu��o do sistema.
% 
% � convencionado que a medi��o de corrente em um elemento acontece sempre
% no terminal 2.
function divpontos = obtainDivPoints(DSSElem,... % Objeto DSSElement, da interface COM
                                     barraV,...  % Lista com barras de medi��o de tens�o
                                     elemI)      % Lista com elementos com medi��o de corrente
divpontos = {};
for aux2=1:size(elemI,2) % percorre a lista de elementos com medi��o de corrente
    % seleciona o elemento de medi��o de corrente dentro da estrutura
    % DSSCirc
    eval(['DSSCirc.SetActiveElement([' '''' 'Line.' elemI{aux2} '''' ']);']);
    % Obt�m as barras as quais o elemento est� conectado
    cell_aux = strsplit(DSSElem.BusNames{2},'.');
    BusName = organizeNames(cell_aux{1});
    % Procura essas barras na lista de pontos de medi��o de tens�o
    index = strfind(organizeNames(barraV),BusName{1});
    index = find(~cellfun(@isempty,index));
    % Caso achar, acrescenta o ponto � lista de pontos que podem dividir o
    % sistema.
    if(~isempty(index))
        divpontos = [divpontos organizeNames(barraV(index))];
    end
end