% Fun��o que testa se uma matriz possui apenas elementos na diagonal
% principal e nas duas diagonais adjacentes e testa se os elementos n�o
% nulos s�o menores do que 1e-7. Os argumentos de sa�da da fun��o s�o: f1 -
% vetor com as posi��es fora da diagonal principal e adjac�ncias nas quais
% existem elementos n�o nulos; e f2 - lista com dados de elementos maiores
% que 1e-7 e suas posi��es na matriz.
function [f1 f2] = testaDiagonalMatriz(matriz)
modulo = abs(matriz);
naonulo = find(modulo~=0);
col = ceil(naonulo*1/size(modulo,1));
lines = mod(naonulo,size(modulo,1));
for aux=1:size(lines,1)
    if(lines(aux,1)==0)
        lines(aux,1)=size(modulo,1);
    end
end
position={'Line','Col','Matriz(line,col)','Abs(Matriz(line,col))'};
for aux=1:size(lines,1)
    position=[position;{lines(aux,1),col(aux,1), matriz(lines(aux,1),col(aux,1)),...
              modulo(lines(aux,1),col(aux,1))}];
end
diagonal = abs(lines-col);
erro1 = find(diagonal>2);
f1 = position(erro1);
delta = cell2mat(position(2:end,4));
erro2 = find(delta>1e-7);
f2 = [position(1,:); position(1+erro2,:)];