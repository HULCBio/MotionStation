% IDDATA/IFFT   周波数領域 IDDATA 信号の IFFT の計算
%
% DATI = IFFT(DAT) は、周波数領域の IDDATA 信号をソートし、IFFT を用い
% て時間領域データに変換します。
%   
% このルーチンは、0からナイキスト周波数までの等間隔な周波数領域データ
% が必要です。
% より正確には:
% DAT.Frequency = [0:df:F] です。ここで、N が奇数の場合、
% df = 2*pi/(N*DAT.Ts) で、F =  pi/DAT.Ts です。また、N が偶数の場合、
% F = pi/DAT.Ts * (1- 1/N) です。ここで N は、周波数の点数です。
%
% 参考: FFT.  
 
 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 17:06:32 $

