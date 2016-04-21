% DINITIAL   離散時間線形システムの応答の初期条件
%
% DINITIAL(A,B,C,D,X0) は、離散システム
% 
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% に対して、初期状態による応答をプロットします。応答を計算する点数は、
% システムの極と零点をベースに自動的に決定します。
%
% DINITIAL(A,B,C,D,X0,N) は、応答を計算する点数 N を設定します。また、
% 左辺に出力引数と設定した場合、
%
%    [Y,X,N] = DINITIAL(A,B,C,D,X0,...)
%
% は、出力(Y)と状態の応答(X)、計算した応答の点数(N)を出力し、スクリーン上
% にプロット表示を行いません。Y は、出力される数の列数をもち、X は状態数
% と同じ数の列数をもっています。
% 
% 参考 : DIMPULSE,DSTEP,DLSIM, INITIAL.


%	Clay M. Thompson  7-6-90
%	Revised ACWG 6-21-92
%	Revised AFP 9-21-94,  PG 4-25-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:45 $
