% O programa tem como funcao oter os principais dados para utilizacao do
% programa opti_ybus.m e armazena-los no arquivo matrizes.mat. As
% informa��es s�o todas exportadas na forma de lista, para facilitar o
% acesso �s informa��es. O conte�do do arquivo matrizes.mat � definido no
% fim deste arquivo, s� rolar para baixo.
% A nomenclatura das barras deve de ser adaptada para que seguisse um padr�o.

% -------------------------------------------------------------------------
% 1) Profilaxia do ambiente Matlab (apaga o passado e demais coisas) -
% comentar esse �tem caso estiver rodando main_program.m ou loop_main.m. A
% linha clearvars s� serve se estiver rodando a partir de loop_main.m. Caso
% n�o for o caso, comentar essa linha. No caso, a vari�vel mainset �
% declarada em main_program, a exist�ncia dele faz com que esse �tem n�o
% seja executado.
% -------------------------------------------------------------------------
if(exist('mainset')) % se existir mainset, est� rodando a partir de main_program
    tempo = clock;
    diftempo = etime(tempo,mainset.time); % diferen�a de tempo em segundos
else % se n�o existe mainset, est� rodando standalone
    close all;
    fclose all;
    clear all;
    clc    
end

% -------------------------------------------------------------------------
% 2) Localiza��o do arquivo a ser simulado
% -------------------------------------------------------------------------
% a) Localiza��o do arquivo pelo usu�rio, independentemente do PC
% -------------------------------------------------------------------------
pasta      = cd;
if(length(pasta)-10 < 0) % pasta tem que terminar com 01. Matlab, que tem 10 caracteres;
    pasta = uigetdir(cd,'Buscar main_program em 01. Matlab');
end    
while(~strcmp(pasta(length(pasta)-10:length(pasta)),'\01. Matlab')) %for�a a buscar na pasta certa
    fprintf('Current Folder deve ser o local do arquivo main_program.m sen�o c�digo n�o vai funcionar.\n');
    pasta = uigetdir(cd,'Buscar main_program em 01. Matlab');
    fprintf('Executando c�digo.\n');
end
pasta_atual = pasta;
pasta=pasta(1:length(pasta)-11); % Um n�vel acima - pasta Leo_Trabalho_Mestrado
addpath([pasta_atual '\gera_dados']); % Armazena as fun��es da pasta gera_dados
addpath([pasta_atual '\common']); % Armazena as fun��es da pasta common



% -------------------------------------------------------------------------
% c) Defini��es particulares para cada um dos sistemas a ser simulado:
% caminho dos arquivos do OpenDSS, barras de deriva��o e linhas de
% deriva��o
% -------------------------------------------------------------------------
% PS: A medi��o de corrente e pot�ncia ocorrer� no terminal 2 do elemento
% de rede descrito em 'elemImed'. A pot�ncia s� ser� medida caso esse 
% terminalestiver conectado em uma barra relacionada na lista 'barraVmed'.

switch escolha
    case 1
        caminho1 = [pasta '\02. OpenDSS\IEEE 13 Barras'];
        caminho2 = [caminho1 '\IEEE13Nodeckt.dss'];
        barraVmed = barraVmed13;
        elemImed = elemImed13;
        barras = 13;

    case 2
        caminho1 = [pasta '\02. OpenDSS\IEEE 34 Barras'];
        caminho2 = [caminho1 '\ieee34Mod1.dss'];
        barraVmed = barraVmed34;
        elemImed = elemImed34;
        barras = 34;
    case 3
        caminho1 = [pasta '\02. OpenDSS\IEEE 37 Barras'];
        caminho2 = [caminho1 '\ieee37.dss'];
        barraVmed = barraVmed37;
        elemImed = elemImed37;
        barras = 37;
    case 4
        caminho1 = [pasta '\02. OpenDSS\IEEE 123 Barras'];
        caminho2 = [caminho1 '\IEEE123Master.dss'];
        barraVmed = barraVmed123;
        elemImed = elemImed123;
        barras = 123;
end
name = ['IEEE' num2str(barras)];
clear barraVmed13 barraVmed34 barraVmed37 barraVmed123
clear elemImed13 elemImed34 elemImed37 elemImed123

% -------------------------------------------------------------------------
% 3) Inicializa��o do OpenDSS
% -------------------------------------------------------------------------
% a) Criando objeto servidor OpenDss - instanciando um objeto da classe
% DSS
% -------------------------------------------------------------------------
% DSS - This interface is the Top interface at the OpenDSSEngine. It is 
% the object reference delivered after connecting to the COM interface and
% it gives access to the other interfaces in OpenDSSEngine.
DSSobj = actxserver('OpenDSSEngine.DSS');

% -------------------------------------------------------------------------
% b) Iniciando servidor
% -------------------------------------------------------------------------
% DSSobj.Start - This method validates the user and start the DSS. Returns
% TRUE if successful. The argument's is a positive integer with no
% specific value.
if ~DSSobj.Start(0)
    disp('Unable to start the OpenDSS Engine')
    return
end

% -------------------------------------------------------------------------
% c) Configurando as vari�veis para as principais interfaces
% -------------------------------------------------------------------------
DSSText = DSSobj.Text;
% DSSobj.Text - This property returns an interface to the Text
%(command-result) command interpreter.
DSSCircuit = DSSobj.ActiveCircuit;
% DSSobj.ActiveCircuit - This property returns an interface to Active circuit.
% AtiveCircuit - This interface can be used to gain access to the features
% and properties of the active circuit. This is one of the most important
% interfaces since it embeds other interfaces, providing access to them as
% a property declaration. The circuit interface is exposed directly by the
% OpenDSSEngine.
DSSSolution = DSSCircuit.Solution;

% -------------------------------------------------------------------------
% d) Construindo comandos para rodar arquivos no OpenDSS - "rodar",
% nesse caso, representado pelo comando "Compile" seguido do nome e caminho
% do arquivo, significa apenas ler o arquivo e armazenar os dados (ao
% contr�rio do que o nome "compilar" sugere). Os c�lculos e a resolu��o do
% circuito ser�o possibilidados a partir do m�todo "Solve".
% -------------------------------------------------------------------------
command_comp1 = ['Compile (' caminho2 ')'];
command_datapath1 = ['set Datapath = (' caminho1 ')'];

% -------------------------------------------------------------------------
% 4. Roda circuito com as cargas e importa a matriz Y com
% cargas, al�m dos vetores de correntes e tens�es nodais
% -------------------------------------------------------------------------
% a) Roda o arquivo com as cargas, roda o fluxo de
% pot�ncia e define a ordem dos n�s
% -------------------------------------------------------------------------
% a.1) Roda o arquivo com as cargas e instancia alguns objetos
% necess�rios
% -------------------------------------------------------------------------
DSSText.command = command_datapath1;
DSSText.command = command_comp1;
% Modifica o modelo das cargas como imped�ncia constante
DSSText.command = 'batchedit Load..* model=2';
% Desabilita todos os reguladores de tens�o
DSSText.command = 'batchedit RegControl..* enabled=false';
% Soluciona o circuito em regime permanente
DSSSolution.Solve;
% Calcula matriz de incid�ncia
DSSText.Command = 'CalcIncMatrix_O';
% Instancia objetos necess�rios
DSSCktElement = DSSCircuit.ActiveCktElement;
DSSElement = DSSCircuit.ActiveElement;
DSSLoads = DSSCircuit.Loads;

% -------------------------------------------------------------------------
% a.2) Verifica se existe possibilidade de divis�o do circuito em �reas de
% medi��o (pontos com medi��o de tens�o e corrente) e pergunta ao usu�rio
% se deseja fazer essa divis�o
% -------------------------------------------------------------------------
escolhadiv = -1;
divpoints = obtainDivPoints(DSSCircuit,DSSElement,barraVmed,elemImed);
if(~isempty(divpoints))
    texto = sprintf('\n\n� poss�vel dividir o sistema em %d �reas de medi��o.\n\n',size(divpoints,2)+1);
    texto = [texto 'Digite 1 para sub-dividir o sistema;\n'];
    texto = [texto 'Digite qualquer outro valor para fazer a estima��o sem divis�o;\n'];
    texto = [texto '\n\nOp�ao:'];
    escolhadiv = input(texto);
    fprintf('\n\n');
end

% -------------------------------------------------------------------------
% a.2) Obt�m lista com todas as barras do circuito. Gera lista na qual as
% barras de medi��o est�o marcadas com '**' e as barras do alimentador com
% '***'. Al�m disso gera lista na qual a nomenclatura das barras est�
% marcada com o n�mero da �rea de medi��o � qual pertencem.
% -------------------------------------------------------------------------
% Obtendo as barras de duas formas pois na vers�o do OpenDSS que peguei
% essas duas vari�veis tinham diferen�as.
nodesODSS1 = [DSSCircuit.YNodeOrder,DSSCircuit.AllNodeNames];
% Ps: a fun��o organizabus modifica o vetor divpoints
[YNodeOrder, divpoints, subredes] = organizebus(barraVmed,DSSCircuit,...
                                              DSSElement,DSSSolution,...
                                              divpoints);
if(escolhadiv==1)
    node_order = sortrows(YNodeOrder(:,3));
    % Lista de barras que considera a �rea de medi��o
else
    node_order = sortrows(YNodeOrder(:,1));
    % Lista de barras que desconsidera a �rea de medi��o
end

% -------------------------------------------------------------------------
% a.3) Conta quantos n�s de medi��o de tens�o existem, contando as fases em
% cada barra.
% -------------------------------------------------------------------------
ptos_medV = size(find(not(cellfun('isempty',strfind(node_order,'*_')))),1)-3;
ptos_medSource = size(find(not(cellfun('isempty',strfind(node_order,'***_')))),1);

% -------------------------------------------------------------------------
% b) Aquisi��o e ordena��o da matriz Y
% -------------------------------------------------------------------------
if(escolhadiv==1)
    Ysistema_list = montaY(DSSCircuit,YNodeOrder(:,3),node_order);
    % Considerando as �reas de medi��o, de modo a quebrar a matriz
    % posteriormente.
else
    Ysistema_list = montaY(DSSCircuit,YNodeOrder(:,1),node_order);
    % Desconsiderando as �reas de medi��o
end

% -------------------------------------------------------------------------
% c) Aquisi��o e ordena��o dos vetores V e I
% -------------------------------------------------------------------------
[Vorder Iorder] = monta_V_e_I(DSSCircuit,YNodeOrder,Ysistema_list,escolhadiv);

% -------------------------------------------------------------------------
% d) Geracao de uma lista com principais dados sobre as cargas. Ps: verify
% � uma vari�vel utilizada para verificar erros na montagem da matriz de
% admit�ncias nodais. Ser� utilizada como entrada de outra fun��o
% posteriormente.
% -------------------------------------------------------------------------
[Load verify] = defineLoad(DSSCircuit,DSSElement,DSSCktElement,DSSLoads,...
                           node_order,barraVmed,barras,escolhadiv);
Load = ungroupLoad(Load,Vorder);

% -------------------------------------------------------------------------
% e) Estimacao correta - Valor a ser encontrado pelo Pattern Search -
% Obtido para fins de avalia��o da fun��o otimizadora
% -------------------------------------------------------------------------
[Yraiz Zraiz Ypos] = defineYRoot(Load);
Sraiz = cell2mat(Load(2:end,11:12));

% -------------------------------------------------------------------------
% f) Gera��o de uma lista com os principais dados sobre o equivalente de
% Thevenin na subesta��o e sobre os pontos de medi��o de corrente
% -------------------------------------------------------------------------
[medI_list ptos_medI] = defineMedI(DSSCircuit,DSSElement,Vorder,barraVmed,...
                         elemImed,node_order,barras,escolhadiv);

% -------------------------------------------------------------------------
% g) Gera��o de uma lista com os principais dados sobre os transformadores,
% para construir restri��o de carregamento
% -------------------------------------------------------------------------
trafoList = defineTrafos(DSSCircuit,DSSElement,node_order,barras,escolhadiv);

% -------------------------------------------------------------------------
% 5. Roda circuito  sem as cargas e importa a matriz Y sem
% cargas
% -------------------------------------------------------------------------
% a) Roda o arquivo sem as cargas, roda o fluxo de pot�ncia e define a
% ordem dos n�s
% -------------------------------------------------------------------------
% a.1) Roda o arquivo  sem as cargas e instancia alguns objetos
% necess�rios
% -------------------------------------------------------------------------
% Remove as cargas do sistema
DSSText.command = 'batchedit Load..* enabled=no';
% Modifica o modelo das cargas como imped�ncia constante
DSSText.command = 'batchedit Load..* model=2';
% Desabilita todos os reguladores de tens�o
DSSText.command = 'batchedit RegControl..* enabled=false';
DSSSolution.Solve;

% -------------------------------------------------------------------------
% a.2) Recebe lista com ordem e nome dos n�s e a modifica, para que na
% ordena��o, os n�s referentes �s barras da subesta��o estejam em primeiro
% lugar, os n�s referentes �s deriva��es estejam logo depois.
% -------------------------------------------------------------------------
nodesODSS2 = [DSSCircuit.YNodeOrder,DSSCircuit.AllNodeNames];
nodes = organizebus(barraVmed,DSSCircuit,DSSElement,DSSSolution,divpoints(1,2:end));

% -------------------------------------------------------------------------
% b) Aquisi��o e ordena��o da matriz Y
% -------------------------------------------------------------------------
if(escolhadiv==1)
    Yrede_list = montaY(DSSCircuit,nodes(1:end,3),node_order);
else
    Yrede_list = montaY(DSSCircuit,nodes(1:end,1),node_order);
end

% -------------------------------------------------------------------------
% 6. Obt�m a matriz de cargas a partir das matrizes com carga e sem carga
% do sistema, monta a mesma matriz de outra forma, a partir das admit�ncias
% das cargas individuais, para compara��o e calcula o erro, para fins de
% debug. O erro � dado pela vari�vel YLoadError.
% -------------------------------------------------------------------------
[Yload_list YLoadError] = defineYLoadError(Ysistema_list,Yrede_list,Load,...
                                      node_order,verify);
clear verify;

% -------------------------------------------------------------------------
% 7. Exportacao dos principais valores para arquivo matrizes.mat na
% pasta que contem o arquivo main_program, al�m de exclus�o de vari�veis
% auxiliares
% -------------------------------------------------------------------------
% clearvars verify;
cd(pasta_atual);
save matrizes.mat barras Vorder Iorder Yrede_list Ysistema_list ...
                  Yload_list medI_list node_order Load Yraiz ...
                  Zraiz Ypos ptos_medV ptos_medI ptos_medSource ...
                  barraVmed elemImed divpoints subredes YLoadError...
                  trafoList Sraiz name escolhadiv
fprintf('Dados principais gerados.\n');

% -------------------------------------------------------------------------
% 8. Limpa o workspace deixando apenas vari�veis necess�rias a outros
% processos
% -------------------------------------------------------------------------
if(~exist('mainset')) % se estiver rodando standalone
    clearvars -except escolhadiv;
else % mainset criada em main_program, gera_dados foi chamado por main_program
    clearvars -except mainset pasta_atual escolhadiv;
end

% -------------------------------------------------------------------------
% 9. Dadas certas condi��es, oferece possibilidade para subdividir o
% sistema
% -------------------------------------------------------------------------
pause(1);
if(escolhadiv==1)
    run('divideSystems.m');
    clear escolhadiv
end

fclose all;
clear ans;

%{
Ps: conteudo do arquivo matrizes.mat:

barras: cont�m o n�mero de barras do circuito simulado

Vorder: tensoes nodais em todas as barras, com os nos na ordem
demonstrada no vetor node_order

Iorder: correntes injetadas em cada no, com os nos na ordem
demonstrada no vetor node_order. Na pratica, apenas as correntes na
subestacao sao nao nulas.

Yrede_list: matriz de admitancia do sistema sem as cargas, com os nos na ordem
demonstrada no vetor node_order

Y_sistema: matriz de admitancia do sistema com as cargas, com os nos na ordem
demonstrada no vetor node_order

Yload_list: diferenca entre a matriz de sistema e de rede

medI_list: lista dos elementos com medi��o de corrente. Para cada elemento,
armazena a matriz de admit�ncia do elemento, as barras em que est�
conectado, o subsistema a que pertence (no caso de divis�o por �reas de
medi��o), a localiza��o das barras em que est� conectado dentro da matriz
de admit�ncias nodais; corrente e pot�ncia medidos em cada terminal do
elemento.

node_order: lista dos nos do sistema ordenados de forma crescente e
conveniente. Se o circuito estiver dividido em subredes, os n�s estar�o
ordenados por subrede. Se contiver pontos de medi��o, estar�o ordenados
ap�s as barras da fonte de tens�o.

Load: tabela com informacoes sobre as cargas. Para cada carga, armazena o
subsistema � que pertence, as barras em que est�o conectadas, a tens�o e a
pot�ncia nominal, a conex�o, a posi��o na matriz de admit�ncias nodais; a
matriz de admit�ncia do elemento de rede carga; os elementos que definem
essa matriz de admit�ncia (cargas equilibradas s�o definidas por apenas 1
elemento); pot�ncia ativa e reativa consumidas pela carga em quest�o.

Yraiz: vetor com admit�ncias das cargas que dever� ser encontrado pela
estima��o de carga em uma estima��o perfeita

Zraiz: vetor com imped�ncias das cargas que dever� ser encontrado pela
estima��o de carga em uma estima��o perfeita

Sraiz: vetor com pot�ncia das cargas que dever� ser encontrado pela
estima��o de carga em uma estima��o perfeita

Ypos: posi��o de cada uma das cargas de Yraiz dentro da matriz de
admit�ncias nodais. Serve para o algoritmo montar a matriz de rede a partir
de cada estima��o de carga;

ptos_medV: quantidade de pontos em que h� medi��o de tens�o;

ptos_medI: quantidade de pontos em que h� medi��o de corrente;

ptos_medSource: quantidade de fases na fonte.

barraVmed: lista de barras com medi��es de tens�o

elemImed: lista com elementos de rede com medi��o de corrente

name: string que representa o nome do circuito (IEEEx tal que x � o n�mero
de barras)

divpoints: lista de pontos da rede em que existe medi��o de tens�o e
corrente. Pode ser utilizado para dividir o circuito em �reas de medi��o,
de modo a facilitar a estima��o de carga.

escolhadiv: assume o valor 1 se o usu�rio escolheu dividir o sistema em
�reas de medi��o e valor 0 caso contr�rio

subredes: array de listas aonde cada lista cont�m as barras pertencentes a
uma �rea de medi��o;

trafoList: lista com os transformadores do sistema. Para cada trafo,
armazena a pot�ncia nominal em kva, matriz de admit�ncia dos elementos,
barras em que est� conectado, subsistema que abrange cada barra, posi��o
dessas barras na matriz Y;

YLoadError: n�mero que indica o erro cometido na montagem das matrizes.
Adv�m da compara��o entre duas montagens da matriz de admit�ncias da rede
de formas diferentes.
%}
