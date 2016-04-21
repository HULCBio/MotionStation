% function out = hinfnorm(sys,ttol,iiloc)
%
% Hamilton法を使って安定なSYSTEM行列のH∞ノルムを計算するか、PKVNORMを使
% って、VARYING行列のH∞ノルムを計算します。2番目の引数は、SYSTEM行列に
% 対して使われ、検索が終了したときの無限大ノルムに対する上界と下界の間の
% 相対的な許容範囲です。オプションの3番目の引数は、初期周波数推定です。
% SYSTEM行列に対して、OUTは、1行3列の行ベクトルで、上界、下界、下界の周
% 波数を要素としています。TTOLのデフォルト値は、0.001です。
%
% 参考: H2SYN, H2NORM, HINFCHK, HINFSYN, HINFFI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
