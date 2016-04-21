% SSBAL   状態空間モデルの対角相似を利用した平衡化
%
%
% [SYS,T] = SSBAL(SYS) は、[T*A/T , T*B ; C/T 0] の行と列が近似的に等しいノ
% ルムをもつような対角相似変換 T を計算するために BALANCE を利用します。
%
% [SYS,T] = SSBAL(SYS,CONDT) は、T の条件数に関する上界 CONDT を指定します。
% デフォルトでは、T に制限はありません(CONDT = inf)。
%
% 状態空間モデルの配列に対して、SSBAL は、配列全体で最大の行ノルムと列ノルム
% を等しくする単一の変換 T を計算します。
%
% 参考 : BALREAL, SS.


% Copyright 1986-2002 The MathWorks, Inc.
