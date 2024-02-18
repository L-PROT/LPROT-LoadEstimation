% Organiza nomenclaturas para serem melhor interpretadas pelo algoritmo. �
% desej�vel que essa fun��o seja aplic�vel a qualquer string ou arrays de
% strings.
% No geral, essa fun��o:
% 1 - remove caracteres n�o num�ricos da nomenclatura das barras, mantendo
% apenas os pontos que separam o nome das barras do n�mero das fases;
% Obs: se caracteres n�o num�ricos foram utilizados na nomenclatura nativa do
% modelo no OpenDSS para distinguir entre duas barras (ex: barra 799 e
% barra 799r), ent�o esse caractere n�o num�rico ser� mantido;
% 2 - depois da a��o 1, a fun��o faz com que a nomenclatura de todas as
% barras, excluindo-se os pontos e n�meros das fases, tenham um comprimento
% fixo de 5 caracteres, completando com zeros a nomenclatura das barras 
% abaixo desse comprimento (ex: barra 799.1.2 ser� 00799.1.2 e barra
% 799r.1.2 ser� 0799r.1.2).
function f = organizeNames(name)
% -------------------------------------------------------------------------
% 1) Organiza a vari�vel de entrada em c�lulas
% -------------------------------------------------------------------------
if(~iscell(name))
    f = {name};
else
    f = name;
end
% -------------------------------------------------------------------------
% 2) Retira partes n�o-num�ricas da nomenclatura. Esse c�digo deve ser
% sempre revisto quando um circuito novo do OpenDSS for inclu�do. A �nica
% parte n�o num�rica que permanece na nomenclatura ap�s esse c�digo � uma
% letra ao final de alguns barramentos, de modo a diferenciar barras
% repetidas (ex: 799r e 799 no mesmo circuito). Desse modo, strings antes
% da numera��o s�o substitu�das por 0 enquanto strings ao final da
% numera��o s�o reduzidas a um �nico caractere, pois nesse caso geralmente
% servem para diferenciar duas barras.
% Id�ias para melhorar a fun��o:
% 1 - a express�o newf = regexprep(f(i,j), '[a-zA-Z]', ''); remove todas as
% letras da string (i,j) do array f e armazena o resultado no array newf.
% 2 - a express�o newf = regexprep(f(i,j), '^[0-9]', ''); remove todos os
% d�gitos que n�o forem num�ricos (caractere "^" quer dizer "n�o")
% da string (i,j) do array f e armazena o resultado no array newf.
% -------------------------------------------------------------------------
f = regexprep(f,'"','');
f = regexprep(f,'SOURCEBUS','0');
f = regexprep(f,'sourcebus','0');
f = regexprep(f,'RG','0');
f = regexprep(f,'rg','0');
f = regexprep(f,'_OPEN','A');
f = regexprep(f,'_open','A');
% -------------------------------------------------------------------------
% 3) Deixa as strings com comprimento fixo, sem contar as marca��es das
% fases. As fases (utilizadas principalmente em barras com liga��es
% monof�sicas) s�o marcadas por um ponto "." seguido da numera��o da
% fase considerada (ex: 609.1 significa fase 1 do barramento 609). Nesse
% caso considerando um comprimento fixo de 5 caracteres, a barra 609 ser�
% nomeada como 00609 e a fase 1 desse barramento ser� 00609.1
% -------------------------------------------------------------------------
for aux1=1:size(f,1)
    for aux2=1:size(f,2)
        cell_aux = strsplit(f{aux1,aux2},'.');
        sizeName = length(cell_aux{1,1});
        for aux3=1:5-sizeName
            f{aux1,aux2} = ['0' f{aux1,aux2}];
        end
    end
end