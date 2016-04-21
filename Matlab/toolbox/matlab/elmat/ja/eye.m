% EYE   単位行列
% 
% EYE(N)は、N行N列の単位行列を出力します。
%
% EYE(M,N)またはEYE([M,N])は、対角要素が1で、それ以外の要素が0のM行N列の
% 行列を出力します。
%
% EYE(SIZE(A))は、Aと同じサイズの単位行列を出力します。
%
% 引数なしの EYE は、スカラー 1 です。
%
% EYE(M,N,CLASSNAME) または EYE([M,N],CLASSNAME) は、対角要素がクラス
% CLASSNAME の 1 で、それ以外の要素が 0 である M行N列の行列です。
%
% 例題:
%      x = eye(2,3,'int8');
%
% 参考 SPEYE, ONES, ZEROS, RAND, RANDN.

%   Copyright 1984-2003 The MathWorks, Inc. 
