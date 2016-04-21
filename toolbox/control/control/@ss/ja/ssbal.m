% SSBAL   対角相似を利用した状態空間モデルの平衡化
%
% [SYS,T] = SSBAL(SYS) は、[T*A/T , T*B ; C/T 0] の行と列が近似的に等しい
% ノルムをもつような対角相似変換 T を計算するために BALANCE を利用します。
%
% [SYS,T] = SSBAL(SYS,CONDT) は、T の条件数に関する上界 CONDT を指定し
% ます。デフォルトでは、T に制限はありません(CONDT=Inf)。
%
% 一様な状態数をもつ状態空間モデルの配列に対して、SSBAL は、すべての配列
% に対して、最大の行ノルムと列ノルムが等しくなる単一変換 T を計算します。
%
% 参考 : BALREAL, SS.


%   Authors: P. Gahinet and C. Moler, 4-96
%   Copyright 1986-2002 The MathWorks, Inc. 
