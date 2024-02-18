% Dado um vetor "Yest" com as admit�ncias estimadas, utiliza as informa��es
% de conex�o e posi��o das cargas da tabela de cargas "Carga" para montar a
% matriz de admit�ncia nodal das cargas e acrescent�-la � matriz "Ynet" de
% admit�ncia da rede sem as cargas. Depois, utiliza o vetor de correntes
% injetadas/medidas no alimentador para obter uma estimativa das tens�es
% nodais e assim calcular as tens�es nodais "Vest" em todas as barras. Com
% esse resultado, estimar a pot�ncia dissipada nas cargas "Sest" a partir
% da f�rmula Sest = 0.001*abs(Vest)^2*Yest. Essa fun��o trabalha com a hip�tese
% de cargas monof�sicas ou bif�sicas. S dado em kVA.
% 1 - Montar a matriz do sistema a partir das admit�ncias estimadas
% 2 - Calcular as tens�es nodais estimadas
% 3 - Uilizar essas tens�es para calcular a pot�ncia juntamente com a
% admit�ncia estimada.
function [Sest] = defineS(Carga,... % Lista de cargas
                             Iordem,...% Vetor de correntes injetadas
                             Yest,...  % Vetor com admit�ncias estimadas
                             Ynet)     % Matriz de admit�ncia nodal da rede sem cargas
Sest = [];
Ypos = Carga(2:end,8);
Yl = defineYLoad(Yest,Ynet,Ypos);
Ysist = Ynet + Yl;
Vest = Ysist\Iordem;
for aux1 = 1:size(Ypos,1)
    conection = Carga{aux1+1,6};
    if(strcmp(conection,'Fase-Terra'))
        position1 = Ypos{aux1,1}(1,1);
        admitance = complex(Yest(aux1,1),Yest(aux1,2));
        ddp = Vest(position1,1);
        Sest = [Sest; conj((abs(ddp)^2)*admitance)];
    else
        position1 = Ypos{aux1,1}(1,1);
        position2 = Ypos{aux1,1}(3,1);
        admitance = complex(Yest(aux1,1),Yest(aux1,2));
        ddp = Vest(position1,1) - Vest(position2,1);
        Sest = [Sest; conj((abs(ddp)^2)*admitance)];
    end
end
Sest = 0.001*[real(Sest) imag(Sest)];