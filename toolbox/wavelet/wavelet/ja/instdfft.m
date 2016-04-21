% INSTDFFT 非標準的な1次元逆フーリエ変換
% [X,T] = INSTDFFT(XHAT,LOWB,UPPB) は、区間[LOWB,UPPB]上で、2のべき乗等間隔グリ
% ッドにおいて(整数である必要はない)、XHAT の逆非標準 FFT を出力します。出力引数
% は、X で、T = LOWB + [0:n-1]*(UPPB-LOWB)/n により得られる時間間隔T上で計算され、
% 取り出された信号を示しています。すなわち、ここで、n は XHAT の長さです。出力は、
% 長さ n のベクトルとなります。
%
% XHAT の長さは、2のべき乗数でなければなりません。
%
% 参考： FFT, IFFT, NSTDFFT.



%   Copyright 1995-2002 The MathWorks, Inc.
