% Fun��o que escreve os principais resultados do teste no arquivo de log, de modo que
% o usu�rio tenha um log de cada ensaio realizado, caso precise acessar
% resultados anteriores. Os argumentos de entrada s�o:
% * resY - armazena, para cada carga (linhas) os valores (colunas):
% admit�ncia real, admit�ncia estimada, Diferen�a entre os m�dulos da
% admit�ncia real e estimada, diferen�a entre as fases, diferen�a entre as
% partes real e entre as partes imagin�rias. Essas diferen�as s�o expressas
% em termos de valor absoluto e valor percentual, o que totaliza 8 formas
% de c�lculo de erro para a admit�ncia de cada carga.
% * resZ - Idem a resY, utilizando a imped�ncia.
% * maxRes - Armazena os valores m�ximos para cada uma das f�rmulas de erro,
% nas formas absoluta e percentual, considerando imped�ncia e admit�ncia.
% Temos assim, 16 valores a serem armazenados nesse vetor a cada estima��o.
% FreqZ - Tabela de frequ�ncias de erros percentuais para cada uma das 4
% formas de c�lculo de erro (imped�ncia);
% FreqY - Tabela de frequ�ncias de erros percentuais para cada uma das 4
% formas de c�lculo de erro (admit�ncia);
% time - tempo entre o in�cio e o fim da estima��o de carga;
% arq - id do arquivo aonde ser�o escritos os resultados.
% Dominio = 1 - Resolve a fun��o objetivo no dom�nio das admit�ncias;
% Dominio = 2 - Resolve a fun��o objetivo no dom�nio das imped�ncias;
function [] = resultsFile(resY,...
                          resZ,...
                          resS,...
                          time,...
                          arq)
res = [resY resZ resS];
id_res = {'Y','Z','S'};
for aux1 = 1:3
    fprintf(arq,'RESUME %s:\n\n',id_res{aux1});
    straux1 = [id_res{aux1} ' Real'];
    straux2 = [id_res{aux1} ' Estimated'];
    fprintf(arq,'\t%17s\t\t\t%18s\t\t%35s\t\t\t\t',...
                'Node',straux1,straux2);
    for aux2=12:size(res(aux1).resume,2)
        fprintf(arq,'\t\t%20s',res(aux1).resume{1,aux2});
    end
    fprintf(arq,'\n');
    for aux2=2:size(res(aux1).resume,1)
        fprintf(arq,'\t%20s',res(aux1).resume{aux2,1});
        fprintf(arq,'\t\t%10g + (%11g) * i\t\t%12g + (%12g) * i',...
                res(aux1).resume{aux2,2},res(aux1).resume{aux2,3},res(aux1).resume{aux2,4},res(aux1).resume{aux2,5});
        for aux3=12:size(res(aux1).resume,2)
            fprintf(arq,'\t\t%20g',res(aux1).resume{aux2,aux3});
        end
        fprintf(arq,'\n');
    end
    fprintf(arq,'\n\n');
    fprintf(arq,'Tabela de frequencias de erros - %s',id_res{aux1});
    fprintf(arq,'\n\n');
    fprintf(arq,'\t%30s',res(aux1).tabFreq{1,1});
    for aux2=2:size(res(aux1).tabFreq,2)
        fprintf(arq,'\t\t%30s',res(aux1).tabFreq{1,aux2});
    end
    fprintf(arq,'\n');
    for aux2=2:size(res(aux1).tabFreq,1)
        fprintf(arq,'\t%30g',res(aux1).tabFreq{aux2,1});
        for aux3=2:size(res(aux1).tabFreq,2)
            fprintf(arq,'\t\t%30g',res(aux1).tabFreq{aux2,aux3});
        end
        fprintf(arq,'\n');
    end
    fprintf(arq,'\n\n');
    fprintf(arq,'\nMaximum error for %s abs estimation is: %g.\n',id_res{aux1},res(aux1).maxResume{4,2});
    fprintf(arq,'Maximum %s abs error in percent is: %g %%.\n\n',id_res{aux1},res(aux1).maxResume{5,2});
end
fprintf(arq,'\nTime for execution is: %g seconds.\n', time);
    