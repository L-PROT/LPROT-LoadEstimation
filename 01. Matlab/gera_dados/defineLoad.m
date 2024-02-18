% A fun��o abaixo produz uma tabela com informa��es de todas as cargas do
% sistema. Al�m disso, a fun��o produz um n�mero verificador da validade da matriz
% do sistema (verifica). Esse n�mero � a soma de todos os elementos da
% matriz de cargas, ou seja, a soma de todas as admit�ncias monof�sicas e
% trif�sicas em estrela.

function [Carga verifica] = defineLoad(DSSCirc,...      % Elemento DSSCircuit da interface COM do OpenDSS
                                       DSSElem,...      % Elemento DSSElement da interface COM do OpenDSS
                                       DSSCktElem,...   % DSSCktElem - Elemento DSSCktElement da interface COM do OpenDSS
                                       DSSCarga,...     % Elemento DSSLoad da interface COM do OpenDSS
                                       nos_ordem,...    % vetor com o nome das barras previamente ordenado
                                       busmedV,...      % lista com barras nas quais h� medi��o de tens�o.
                                       buses,...        % vetor com o n�mero total de barras do circuito.
                                       choice)          % divis�o do circuito em �reas de medi��o
% -------------------------------------------------------------------------
% a) Defini��o da classe carga como ativa
% -------------------------------------------------------------------------
DSSCirc.SetActiveClass('Load');

% -------------------------------------------------------------------------
% b) M�todo que define a primeira carga da lista como Elemento Ativo
% -------------------------------------------------------------------------
aux1 = DSSCarga.First;
aux2 = DSSCirc.FirstElement;

% -------------------------------------------------------------------------
% c) Informa��es dispon�veis na lista de cargas
% -------------------------------------------------------------------------
Carga = {'Subsystem' 'Name','Tensao(V)','W','VAr','Conn','Bus','Ypos','Yprim','Ycarga','P1(kW)','Q1(kVAr)','P2(kW)','Q2(kVAr)','P3(kW)','Q3(kVAr)','PN(kW)','QN(kVAr)'};

% -------------------------------------------------------------------------
% d) Vari�veis a serem preenchidas
% -------------------------------------------------------------------------
Conn = ''; % Conex�o de cada carga
Ycarga = 0; % Admit�ncia pr�pria de cada carga (no caso de carga 3F utilizo  admit�ncia entre fases);
Yprim = []; % Matriz de admit�ncia primitiva de cada carga;
position = []; % posi��o de cada carga na matriz de admit�ncia da rede
potencia = []; % vetor com o fluxo de pot�ncia em cada carga
verifica = 0; % armazena a soma das admit�ncias das cargas fase terra, de
              % modo a verificar se a matriz de carga � diagonal

% -------------------------------------------------------------------------
% e) Loop que percorre todas as cargas, verifica a conex�o delas com o
% sistema, obt�m a matriz de admit�ncia primitiva e escolhe um valor para
% representar essa matriz, verificando tamb�m em qual posi�ao da matriz de
% rede essa carga est� conectada, entre outros dados
% -------------------------------------------------------------------------
while(aux1 > 0) % aux1 sempre aponta para uma das cargas e chega em 0 no fim da lista
    
    % Obt�m a matriz de admit�ncia prim�ria
    Yprim = DSSElem.Yprim;
    aux1 = sqrt(size(Yprim,2)/2);
    Xreal = reshape(Yprim(1:2:end),[aux1,aux1]);
    Ximag = reshape(Yprim(2:2:end),[aux1,aux1]);
    Yprim = complex(Xreal',Ximag');
    no = organizeNames(DSSElem.BusNames);
    cell_aux = splitPhases(no{1,1});
    for aux3=1:size(cell_aux,1)
        index = strfind(lower(nos_ordem),lower(cell_aux{aux3,1}));
        index = find(not(cellfun('isempty',index)));
        position = [position; index];
    end
    no = nos_ordem(position);
    % Define a conex�o para cada carga e a admit�ncia pr�pria
    switch DSSCktElem.NumPhases % Confere o n�mero de fases
        case 3 % Trif�sico
            if(DSSCarga.IsDelta == 1) % Carga em trif�sico-Delta
                Conn = '3F Delta';
                position = [position(1,1)*ones(3,1),position;...
                            position(2,1)*ones(3,1),position;...
                            position(3,1)*ones(3,1),position];
                Ycarga = [-Yprim(1,2);-Yprim(2,3);-Yprim(1,3)];
            else % Conex�o Estrela
                if(size(cell_aux,1)==4) % Conex�o Estrela com neutro n�o aterrado.
                    Conn = '3FN Wye';
                    position = [position(1,1)*ones(4,1),position;...
                                position(2,1)*ones(4,1),position;...
                                position(3,1)*ones(4,1),position;...
                                position(4,1)*ones(4,1),position];
                    Ycarga = [Yprim(1,1);Yprim(2,2);Yprim(3,3);Yprim(4,4)];
                    verifica = verifica + Yprim(4,4)-Yprim(3,3)-Yprim(2,2)-Yprim(1,1);
                else % Conex�o Estrela com neutro aterrado
                    Conn = '3FT Wye';
                    position = [position(1,1)*ones(3,1),position;...
                                position(2,1)*ones(3,1),position;...
                                position(3,1)*ones(3,1),position];
                    Ycarga = [Yprim(1,1);Yprim(2,2);Yprim(3,3)];
                    verifica = verifica + sum(Ycarga);
                end
            end
        case 1
            switch size(cell_aux,1)
                case 2
                    Conn = 'Fase-Fase';
                    position = [position(1,1)*ones(2,1),position;...
                                position(2,1)*ones(2,1),position];
                case 1
                    Conn = 'Fase-Terra';
                    verifica = verifica + Yprim(1,1);
                    position = [position, position];
            end
            Ycarga = Yprim(1,1);
    end

    % Obt�m a �rea de medi��o
    if(choice==1)
        BusNames = organizeNames(DSSElem.BusNames);
        BusNames = strsplit(BusNames{1},'.');
        index = strfind(lower(nos_ordem),lower(BusNames{1,1}));
        index = find(not(cellfun('isempty',index)));
        subsystem = nos_ordem{index(1)}(1:2);
    else
        subsystem = '01';
    end
     
    % Obt�m o fluxo de pot�ncia para cada carga
    potencia = zeros(1,8);
    potencia(1:size(DSSElem.Powers,2))=DSSElem.Powers;
    
    % Preenche a lista de cargas com os dados necess�rios
    Carga = [Carga; subsystem, [DSSElem.BusNames{1} ' - ' DSSCarga.Name], DSSCarga.kV*1000, DSSCarga.kW*1000,DSSCarga.kvar*1000,Conn,{no}, position,Yprim,Ycarga,num2cell(potencia)];
    
    % Aponta para pr�xima carga da lista, se n�o tiver nenhuma aux1 fica
    % igual a zero.
    aux1 = DSSCarga.Next;
    aux2 = DSSCirc.NextElement;
    position = [];
end;

% -------------------------------------------------------------------------
% f) Ordena��o das cargas de acordo com nos_ordem
% -------------------------------------------------------------------------
if(choice==1)
    Carga = [Carga(1,:);sortrows(Carga(2:end,:),[1 2])];
else
    Carga = [Carga(1,:);sortrows(Carga(2:end,:),2)];
end
%{
Formato da lista de cargas:
* Name: nome de cada uma das cargas, como configurado no OpenDSS;
* Name: nome de cada uma das cargas, como configurado no OpenDSS;
* Tens�o(V): Tens�o nominal, em Volts.
* W: Pot�ncia ativa nominal, em Watts.
* Conn: conex�o da carga, pode ser Fase-Fase, Fase-Terra, 3F Wye ou 3F Delta
* Bus: barramento ao qual a carga est� conectada.
* Ypos: posi��o [linha coluna] em que a admit�ncia da carga entra na matriz
de admit�ncias do sistema;
* Yprim: matriz prim�ria de admit�ncia da carga;
* Ycarga: elementos necess�rios para definir a matriz de admit�ncia
prim�ria. O n�mero desses elementos define o grau de liberdade na
determina��o da carga. Para cargas monof�sicas e bif�sicas, Ycarga � a
pr�pria admit�ncia entre fases (ou entre fase e terra). Para cargas
trif�sicas em tri�ngulo, o elemento s�o as 3 admit�ncias entre as fases (Yab,
Ybc, Yca). Para cargas trif�sicas em estrela, Ycarga s�o as admit�ncias
entre cada fase e o neutro.
* Pn, Qn: pot�ncias ativa e reativa na fase n de acordo com simula��o do
OpenDSS;
%}