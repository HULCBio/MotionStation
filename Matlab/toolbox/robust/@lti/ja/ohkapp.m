% OHKAPP 最適ハンケルノルム近似 (安定プラント)
%
% [SS_X,SS_Y,AUG] = OHKAPP(SS_,MRTYPE,IN)、または、
% [AX,BX,CX,DX,AY,BY,CY,DY,AUG] = OHKAPP(A,B,C,D,MRTYPE,IN) は、デスクリ
% プタシステムによる最適ハンケルノルム近似を算出します。
% 
% (AX,BX,CX,DX)は低次元化モデルで、(AY,BY,CY,DY)は解の非因果部です。
%
%   (G - Ghed)の無限大ノルム <= 
%            K番目からn番目のハンケル特異値までの和の2倍
% 
% 平衡化は必要ありません。
%
%   mrtype = 1の場合、inは低次元化モデルの次数k。
%   mrtype = 2の場合、トータルの誤差が"in"より小さくなる低次元化モデルを
%                     算出。
%   mrtype = 3の場合、ハンケル特異値を表示し、次数kの入力を促します。
%                    (この場合、"in"を指定する必要はありません。)
%
% AUG = [最大ハンケル特異値 ,削除された状態(s) ,誤差範囲 ,...
%            ハンケル特異値の集合]



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
