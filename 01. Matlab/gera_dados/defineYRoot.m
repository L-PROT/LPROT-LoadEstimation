% Fun��o que extrai da vari�vel lista de cargas (Load) a admit�ncia de cada
% uma das cargas e constr�i o vetor de admit�ncias que dever� minimizar a
% fun��o objetivo. Tamb�m constr�i o vetor com as posi��es ocupadas por
% cada uma das cargas dentro das matrizes de carga e do sistema.
% Assim, o n�mero de elementos do vetor constru�do � igual ao n�mero de 
% graus de liberdade da fun��o de estima��o de carga. Esse vetor dever�
% produzir um valor m�nimo (desprez�vel) quando utilizando na fun��o opti_ybus.
% Ele � necess�rio para avaliar a qualidade da estima��o de carga feita 
% pelo Pattern Search.
% A modifica��o introduzida quanto � admit�ncia da lista de cargas � que as
% cargas trif�sicas, quando estiverem em estrela, devem ser modeladas
% utilizando-se a representa��o tri�ngulo equivalente. Assim, neste caso,
% modifica-se as admit�ncias entre fase e terra pelas admit�ncias entre
% fases na configura��o equivalente.
% Desse modo, a fun��o objetivo, ao montar a matriz do sistema a partir do
% vetor de cargas estimadas, montar� todas as cargas trif�sicas na
% representa��o tri�ngulo. A solu��o encontrada pelo Pattern Search dever�
% ser comparada com a representa��o em tri�ngulo das cargas para produzir o
% erro.
% As cargas monof�sicas, bif�sicas e trif�sicas em Delta s�o modeladas
% assim como na coluna Ycarga, da lista de cargas.
% Os argumentos de entrada s�o:
% * Carga - lista de cargas 'Load' armazenada em matrizes.mat
function [Y Z Yposition] = defineYRoot(Carga)
Ycomplex = [];
Yposition = [];
for aux=2:size(Carga,1)
    conection = Carga{aux,6};
    admitance = Carga{aux,10};
    position = Carga{aux,8};
    if(strcmp(conection,'3FN Wye')) % estrela isolada ser� modelada como tri�ngulo
        ya = admitance(1,1);
        yb = admitance(2,1);
        yc = admitance(3,1);
        yab = (ya*yb)/(ya+yb+yc);
        ybc = (yb*yc)/(ya+yb+yc);
        yca = (yc*ya)/(ya+yb+yc);
        Ycomplex = [Ycomplex;yab;ybc;yca];
        Yposition = [Yposition; {position}];
    elseif(strcmp(conection,'3FT Wye'))
        Ycomplex = [Ycomplex;admitance];
        Yposition = [Yposition; {position(1,:)};{position(5,:)};{position(9,:)}];
    else
        Ycomplex = [Ycomplex;admitance];
        Yposition = [Yposition; {position}];
    end
end

Zcomplex = 1./Ycomplex;
Y = [real(Ycomplex) imag(Ycomplex)];
Z = [real(Zcomplex) imag(Zcomplex)];

