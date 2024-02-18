% 	recebe uma matriz vector [a_ij] de dimens�o n_l�2 e retorna uma matriz
%   [b_ij] de dimens�o ?2n?_l�1, tal que:[b_i1]=[a_i1],se i?n_l; e 
%   [b_i1]=[a_(i-n_l)2 ],se i>n_l

function [v] = modifyVector(vector)
    n = size(vector,1);
    v = [vector(1:n,1);vector(1:n,2)]';