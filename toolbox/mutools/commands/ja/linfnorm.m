% function out = linfnorm(sys,ttol,iiloc)
%
% Hamilton法を使って、安定または不安定なSYSTEM行列のL∞ノルムを計算しま
% す。または、PKVNORMを使って、VARYING行列のL∞ノルムを計算します。2番目
% の引数は、SYSTEM行列に対して使われ、検索が終了したときの無限大ノルムに
% 対する上界と下界の間の相対的な許容範囲です。オプションの3番目の引数は、
% 初期周波数推定です。SYSTEM行列に対して、OUTは、1行3列の行ベクトルで、
% 下界、上界、下界の周波数を要素としています。TTOLのデフォルト値は、
% 0.001です。安定性のチェックが行われない点を除いて、HINFNORMと同じです。
%



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
