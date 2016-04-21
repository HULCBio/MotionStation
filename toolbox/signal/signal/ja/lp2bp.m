% LP2BP ローパスフィルタプロトタイプをバンドパスアナログフィルタへ変換 
%
% [NUMT,DENT] = LP2BP(NUM,DEN,Wo,Bw) は、単位カットオフ周波数をもつアナ
% ログローパスフィルタのプロトタイプNUM(s)/DEN(s)を希望の帯域幅 Bw とカ
% ットオフ周波数 Wo をもつバンドパスフィルタに変換します。
%
% [AT,BT,CT,DT] = LP2BP(A,B,C,D,Wo,Bw)は、連続系状態空間の形で表されるフ
% ィルタに変換します。
%
% 参考：   BILINEAR, IMPINVAR, LP2LP, LP2BS, LP2HP



%   Copyright 1988-2002 The MathWorks, Inc.
