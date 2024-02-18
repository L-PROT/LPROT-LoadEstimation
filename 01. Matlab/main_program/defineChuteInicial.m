% Fun��o que, a partir da lista de cargas gerada em 'gera_dados' e das
% tens�es nodais do circuito simulado, define um valor inicial para a
% estima��o da imped�ncia das cargas, dado por Vnom^2/Sinicio, aonde Vnom �
% a tens�o nominal de cada carga e Sinicio = Sfonte*Snom/sum(Snom), ou
% seja, Sinicio � a porcentagem da pot�ncia medida na subesta��o
% correspondente � pot�ncia nominal da carga em rela��o � pot�ncia total
% instalada. Os argumentos de entrada s�o:
% * Carga - Lista de cargas 'Load' salva no arquivo matrizes.mat
% * Sfonte - Pot�ncia medida na sa�da da subesta��o
% Dominio = 1 - Resolve a fun��o objetivo no dom�nio das admit�ncias;
% Dominio = 2 - Resolve a fun��o objetivo no dom�nio das imped�ncias;
function [chute] = defineChuteInicial(Carga,Sfonte,dominio)

escolha = -1;
texto = '\n\nDigite 1 para re-utilizar resultados como chute inicial.\n';
texto = [texto 'Digite qualquer outra tecla caso contr�rio.'];
texto = [texto '\n\nOp�ao:'];
escolha = input(texto);
fprintf('\n\n');
if(escolha==1)
    [file path] = uigetfile('*.mat','Localizar arquivo .mat com vari�vel vetorps');
    command = ['load(' '''' path file '''' ',' '''' 'search' '''' ');' ];
    eval(command);
    chute = search.vetorps;
else
    Pnom = Carga(2:end,4);
    Qnom = Carga(2:end,5);
    Vnom = Carga(2:end,3);
    Pnom = cell2mat(Pnom);
    Qnom = cell2mat(Qnom);
    Snom = complex(Pnom,Qnom);
    Vnom = cell2mat(Vnom);

    % Chute inicial 1 - divis�o proporcional, mesmo fator de pot�ncia (fator da
    % soma das pot�ncias na sa�da da subesta��o);
    Spercent = abs(Snom)/sum(abs(Snom));
    Sinicio = (sum(1000*Sfonte))*Spercent;

    % Chute inicial 2 - divis�o proporcional, fator de pot�ncia correto;
    % Spercent = abs(Snom)/sum(abs(Snom));
    % Sinicio = abs(sum(-1000*Sfonte))*Spercent;
    % Sinicio = Sinicio.*exp(i*angle(Snom));

    % Chute inicial 3 - divis�o proporcional, mesmo fator de pot�ncia
    % (0.75);
    % Spercent = abs(Snom)/sum(abs(Snom));
    % Sinicio = abs(sum(-1000*Sfonte))*Spercent;
    % Sinicio = Sinicio.*exp(i*acos(0.75));

    % Chute Inicial 4 - divis�o proporcional, considerando as pot�ncias
    % complexas, fator de pot�ncia diferente para cada, dependendo do fator
    % real da carga e das pot�ncias medidas na fonte.
    % Spercent = Snom/sum(Snom);
    % Sinicio = sum(-1000*Sfonte)*Spercent;
    
    Yaux = [];

    for aux = 2:size(Carga,1)
        if(strcmp(Carga{aux,6},'Fase-Terra') || strcmp(Carga{aux,6},'Fase-Fase'))
            y = conj(Sinicio(aux-1,1))/Vnom(aux-1,1)^2;
            Yaux = [Yaux;y];
        else
            y = conj(Sinicio(aux-1,1))/(3*Vnom(aux-1,1)^2);
            Yaux = [Yaux;y;y;y];
        end
    end

    Zaux = 1./Yaux;
    switch dominio
        case 1
            chute = [real(Yaux); imag(Yaux)]';
        case 2
            chute = [real(Zaux); imag(Zaux)]';
    end
end