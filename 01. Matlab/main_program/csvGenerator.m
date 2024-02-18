% Gera um arquivo csv com principais resultados dos testes, para serem
% importados para a tese em latex
function csvGenerator(resX,... % estrutura com os resultados dos testes para a grandeza X (S, Y ou Z)
                      arqX)    % estrutura com os dados dos arquivos para resultados na grandeza X
% salva vari�vel results*.resume
resX.Tresume = cell2table([resX.resume(:,1:5),resX.resume(:,12),...
                               resX.resume(:,15:17)]);
writetable(resX.Tresume,arqX.nomearqresume);
% salva vari�vel results*.tabFreq
resX.TtabFreq = cell2table(resX.tabFreq(:,[1,3,9:2:13]));
writetable(resX.TtabFreq,arqX.nomearqtabFreq);
% salva vari�vel results*.compare1
writetable(cell2table(resX.compare1),arqX.compare1);
% salva vari�vel results*.compare2
writetable(cell2table(resX.compare2),arqX.compare2);

