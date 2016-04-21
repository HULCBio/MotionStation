% LP2LP ローパスフィルタプロトタイプをローパスアナログフィルタへ変換
%
% [NUMT,DENT] = LP2LP(NUM,DEN,Wo) は、単位カットオフ周波数をもつアナログ
% ローパスフィルタのプロトタイプ NUM(s)/DEN(s) をカットオフ周波数 Wo(rad
% /sec) をもつローパスフィルタに変換します。
%
% [AT,BT,CT,DT] = LP2LP(A,B,C,D,Wo) は、状態空間の型で表されるフィルタに
% 変換します。  
%
% 参考：   BILINEAR, IMPINVAR, LP2BP, LP2BS, LP2HP



%   Copyright 1988-2002 The MathWorks, Inc.
