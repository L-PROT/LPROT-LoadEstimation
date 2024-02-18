% Rotina que recebe o m�todo de busca e a vari�vel estruturada 'search' e
% devolve a vari�vel estruturada options, com as op��es de busca
% necess�rias para executar a fun��o patternsearch.

% PS: todos os m�todos de busca foram testados e o que produz melhor
% resultados no contexto atual s�o as op��es padr�o. Muitos dos resultados
% em variar apenas uma op��o est�o descritos abaixo.

function opt = confOptions(metodo,...    % 0 para PS e 1 para GA
                           busca)    % estrutura com configura��es de busca
if(metodo == 0)
    opt = psoptimset;
    % O comando acima cria todas os atributos de options que ser�o
    % inicializados pelo matlab ao aplicar o PS. Ele tamb�m pode ser
    % utilizado para definir o valor de certos atributos, tal como no
    % exemplo:
    % opt  = psoptimset('TolFun',1E-12,'TimeLimit',Inf,'InitialMeshSize',4.0,...
    %                   'PollMethod','GPSPositiveBasis2N','CompletePoll','on',...
    %                   'Vectorized','off','MaxIter',1000000,'PlotFcns',...
    %                   search.PlotFunctions);
    % Campos de options cuja modifica��o afeta o algoritmo
    % busca.PlotFunctions = {@psplotbestf,@psplotfuncount,@psplotmeshsize};
    % opt.PlotFcns = busca.PlotFunctions;
    opt.MaxFunEvals = Inf;
    opt.MaxIter = Inf;
    opt.UseParallel = 1;
    opt.PollingOrder = 'Success';
    % opt.InitialMeshSize = 8; * N�o afeta desempenho do algoritmo padr�o;
    % opt.CompletePoll = 'on'; * Piora desempenho;
    % opt.PollMethod = 'MADSPositiveBasis2N'; * Piora desempenho;
    % opt.PollingOrder = 'Success'; * Piora desempenho;
    % search.PlotFunctions = {};
    % opt.MeshAccelerator = 'on';
    % opt.PollingOrder = 'Random';  * Piora desempenho;
    % opt.ScaleMesh = 'off'; * N�o modifica desempenho;
    % opt.TolMesh = 1e-12;
    % opt.TolX = 1e-12;
    % opt.MeshExpansion = 1;
    % opt.MeshContration = 2;
    % opt.Display = 'diagnose';

else
    busca.PlotFunctions = {@gaplotbestf @gaplotbestindiv @gaplotdistance};
    opt = gaoptimset;
    opt = gaoptimset(opt,'PlotFcns',busca.PlotFunctions);
%     opt = gaoptimset(opt,'PopulationSize', PopulationSize_Data);
%     opt = gaoptimset(opt,'Display', 'off');
end
