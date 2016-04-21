% NSTDFFT 　非標準1次元高速フーリエ変換
% [XHAT,OMEGA] = NSTDFFT(X,LOWB,UPPB) は、区間 [LOWB,UPPB] において、2のべき乗の
% 等間隔グリッド(整数である必要はありません)上でサンプリングされた信号 X の非標
% 準高速フーリエ変換を出力します。
%
% 出力引数は XHAT で、OMEGA = [-n:2:n-2]/(2*(UPPB-LOWB)) によって与えられた区間 
% OMEGA 上で計算された X のシフトされた FFT です。ここで、n は X の長さを指して
% います。出力は、長さ n のベクトルです。
%
% X の長さは、2のべき乗でなければなりません。
%
% 参考： FFT, FFTSHIFT, INSTDFFT.



%   Copyright 1995-2002 The MathWorks, Inc.
