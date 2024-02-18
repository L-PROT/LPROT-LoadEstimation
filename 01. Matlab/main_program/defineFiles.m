% Fun��o que define o nome dos arquivos de sa�da do algoritmo. 
% Os arquivos de sa�da ser�o armazenados em uma pasta cuja estrutura do
% nome ser� dada na forma:
% IEEE<NOME>_<DOMINIO>_<HORARIO>_v<VERSION>_mv<MV>_mI<MI>_<NC>;
% Aonde:
% <NOME>: Identificador do circuito simulado. Geralmente � o n�mero de
% barras. Quando for um subsistema ser� indicado pelo n�mero de barras do
% circuito maior mais o n�mero do subsistema. Ex: IEEE13_1 � o subsistema 1
% do circuito IEEE 13 barras.
% <DOMINIO>: Dom�nio no qual o Pattern Search foi executado. Y para
% admit�ncias e Z para imped�ncias.
% <HOR�RIO>:  String com hor�rio em que a simula��o foi realizada. O
% formato da string � <ANO><M�S><DIA><HORA><MINUTO>.
% <VERSION>: Qual fun��o objetivo est� sendo executada.
% <MV>: n�mero de pontos com medi��o de tens�o, contando as fases. Uma
% barra trif�sica acrescenta 3 pontos com medi��o de tens�o.
% <MI>: n�mero de pontos com medi��o de corrente, contando as fases.
% <NC>: indica se a simula��o foi realizada utilizando-se restri��es n�o
% lineares. A utiliza��o dessas restri��es � marcada a partir da string
% 'NC'. Se o nome o arquivo n�o contiver essa string, restri��es n�o
% lineares n�o se aplicam.
% As sa�das dessa fun��o consistem de quatro vari�veis estruturadas, cujos
% campos s�o descritos abaixo:
% * arq.folder/arq().folder - Caminho e nome da pasta em que ser�o gravados os 
%   arquivos de sa�da, dentro da pasta 'log'.
% * arq.nomearqlog - caminho e nome do arquivo 'Log.txt'contendo os
%   principais dados e resultados da simula��o em modo texto.
% * arq.nomearqmat - nome do arquivo '.mat' que cont�m as vari�veis do
%   matlab utilizadas e geradas pela simula��o, para posterior
%   processamento caso precise
% * arq().nomearqfig - nome do arquivo.fig que cont�m o histograma gerado
%   pela simula��o
% * arq().nomearqresume - nome do arquivo '.csv' com o resumo da estima��o
%   de carga realizada, contendo os resultados e erros individuais por
%   barra
% * arq().nomearqtabFreq - nome do arquivo '.csv' contendo a tabela de
%   frequ�ncias para os erros da estima��o de carga realizada;
% * arq().compare1 - nome do arquivo '.csv' contendo a compara��o entre os
%   erros da estimativa realizada com os erros referentes ao chute inicial
% * arq().compare2 - idem � arq().compare1, mas utilizando figuras de
%   m�rito diferentes, como erro m�ximo, m�dia de erros e desvio padr�o
% OBS: podem ser gerados '.csv' para a vari�vel maxResume, que define erro
% m�ximo, m�dia e desvio padr�o da estimativa gerada.

function [arq arqY arqZ arqS] = defineFiles(confprinc,... % estrutura com principais configura��es
                                            data,...      % estrutura com dados do circuito
                                            busca)        % estrutura com principais dados do PS
horario = clock;
tagtempo{1} = num2str(horario(1));
for aux1 = 2:5
    tagtempo{aux1} = num2str(horario(aux1));
    sizeName = length(num2str(horario(aux1)));
    for aux2 = 1:2-sizeName
        tagtempo{aux1} = ['0' tagtempo{aux1}];
    end
end
horario = [tagtempo{1} tagtempo{2} tagtempo{3} tagtempo{4} ...
           tagtempo{5}];
% Testar nome de subsistemas se funciona
if(isequal(busca.nonlcon,[]))
    NC = '';
else
    NC = '_NC';
end

arq.folder = ['log/' data.name '_' confprinc.string_dom '_'...
              horario '_v' num2str(confprinc.version) '_mV'...
              num2str(data.ptos_medV) '_mI' num2str(data.ptos_medI)...
              NC '/'];
arqY.folder = [arq.folder 'Results Y/'];
arqZ.folder = [arq.folder 'Results Z/'];
arqS.folder = [arq.folder 'Results S/'];
arq.nomearqlog = [arq.folder 'Log.txt'];
arq.nomearqmat = [arq.folder 'variables.mat'];
arqY.nomearqfig = [arqY.folder 'FigY.fig'];
arqY.nomearqresume = [arqY.folder 'ResumeY.csv'];
arqY.nomearqtabFreq = [arqY.folder 'TabFreqY.csv'];
arqZ.nomearqfig = [arqZ.folder 'FigZ.fig'];
arqZ.nomearqresume = [arqZ.folder 'ResumeZ.csv'];
arqZ.nomearqtabFreq = [arqZ.folder 'TabFreqZ.csv'];
arqS.nomearqfig = [arqS.folder 'FigS.fig'];
arqS.nomearqresume = [arqS.folder 'ResumeS.csv'];
arqS.nomearqtabFreq = [arqS.folder 'TabFreqS.csv'];
arqY.compare1 = [arqY.folder 'Ycomp1.csv'];
arqZ.compare1 = [arqZ.folder 'Zcomp1.csv'];
arqS.compare1 = [arqS.folder 'Scomp1.csv'];
arqY.compare2 = [arqY.folder 'Ycomp2.csv'];
arqZ.compare2 = [arqZ.folder 'Zcomp2.csv'];
arqS.compare2 = [arqS.folder 'Scomp2.csv'];
mkdir(arq.folder);
mkdir(arqY.folder);
mkdir(arqZ.folder);
mkdir(arqS.folder);


% arq.nomearqmat = [arq.nomearqlog(1:length(arq.nomearqlog)-4) 'variables.mat'];
% arqY.nomearqfig = [arq.nomearqlog(1:length(arq.nomearqlog)-4) 'Y.fig'];
% arqY.nomearqresume = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_resumeY.csv'];
% arqY.nomearqtabFreq = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_tabFreqY.csv'];
% arqZ.nomearqfig = [arq.nomearqlog(1:length(arq.nomearqlog)-4) 'Z.fig'];
% arqZ.nomearqresume = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_resumeZ.csv'];
% arqZ.nomearqtabFreq = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_tabFreqZ.csv'];
% arqS.nomearqfig = [arq.nomearqlog(1:length(arq.nomearqlog)-4) 'S.fig'];
% arqS.nomearqresume = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_resumeS.csv'];
% arqS.nomearqtabFreq = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_tabFreqS.csv'];
% arqY.compare1 = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_Ycomp1.csv'];
% arqZ.compare1 = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_Zcomp1.csv'];
% arqS.compare1 = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_Scomp1.csv'];
% arqY.compare2 = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_Ycomp2.csv'];
% arqZ.compare2 = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_Zcomp2.csv'];
% arqS.compare2 = [arq.nomearqlog(1:length(arq.nomearqlog)-4) '_Scomp2.csv'];