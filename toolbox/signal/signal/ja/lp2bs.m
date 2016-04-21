% LP2BS ローパスフィルタプロトタイプをバンドストップアナログフィルタへ変
% 換
%
% [NUMT,DENT] = LP2BS(NUM,DEN,Wo,Bw) は、単位カットオフ周波数をもつアナ
% ログローパスフィルタのプロトタイプ NUM(s)/DEN(s) を帯域幅 Bw とカット
% オフ周波数 Wo をもつバンドストップフィルタに変換します。
% 
% [AT,BT,CT,DT] = LP2BS(A,B,C,D,Wo,Bw) は、状態空間の型で表されるフィル
% タに変換します。 
%
% 参考：   BILINEAR, IMPINVAR, LP2BP, LP2LP, LP2HP



%   Copyright 1988-2002 The MathWorks, Inc.
