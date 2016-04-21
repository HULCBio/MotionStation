% LP2HP ローパスフィルタプロトタイプをハイパスアナログフィルタへ変換
%
% [NUMT,DENT] = LP2HP(NUM,DEN,Wo)は、単位カットオフ周波数をもつアナログ
% ローパスフィルタのプロトタイプ NUM(s)/DEN(s)を単位カットオフ周波数Woを
% もつハイパスフィルタに変換します。
%
% [AT,BT,CT,DT] = LP2HP(A,B,C,D,Wo)は、状態空間の型で表されるフィルタに
% 変換します。
%
% 参考：   BILINEAR, IMPINVAR, LP2BP, LP2BS, LP2LP



%   Copyright 1988-2002 The MathWorks, Inc.
