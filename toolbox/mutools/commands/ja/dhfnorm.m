% function out = dhfnorm(sys,ttol,h,iiloc)
%
% 双一次変換とHINFNORMを使って、安定な離散時間SYSTEM行列SYSのH∞ノルムを
% 計算、またはPKVNORMを使ってVARYING行列のH∞ノルムを計算します。2番目の
% 引数TTOLは、SYSTEM行列に対して使われ、検索が終了したときの無限大ノルム
% に対する上界と下界の間の相対的な許容範囲です。TTOLはオプションで、デフ
% ォルト値が0.001です。オプションの3番目の引数Hは、サンプル時間です(デフ
% ォルト = 1)。オプションの4番目の引数IILOCは、最悪ケースの周波数に対す
% る初期周波数推定値です。
%
% SYSTEM行列に対して、OUTは、1行3列の行ベクトルで、下界、上界、下界の周
% 波数を要素としています。CONSTANT行列に対して、OUTは、1行3列の行ベクト
% ルで、最初の2つの要素は行列のノルムで、周波数は0です。OUTは、SYSがVA-
% RYING行列の場合、SYSのPKVNORMです。
%
% 参考: DHFSYN, HINFNORM, H2SYN, H2NORM, HINFCHK, HINFSYN,
%       HINFFI, NORM, PKVNORM, SDHFNORM, SDHFSYN.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
