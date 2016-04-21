% HILBERT は、Hilbert 変換を使った、離散時間解析的信号を計算します。
% X = HILBERT(Xr) は、いわゆる離散時間解析信号 X = Xr + i*Xi を計算しま
% す。ここで、Xi は実数ベクトル Xr の Hilbert 変換です。入力 Xr が複素数
% の場合、実数部のみが使われます。すなわち、 Xr=real(Xr) です。Xr が行列
% の場合、HILBERT は、Xr の列単位に操作します。
%
% HILBERT(Xr,N) は、N 点の Hilbert 変換を計算します。Xr は、長さが N よ
% り短い場合、ゼロを付加し、長い場合は打ち切ります。 
%
% 離散時間解析信号 X に対して、fft(X) の後半分はゼロになり、fft(X) の最
% 初(DC)と中央(Nyquist)は、実数になります。
%
% 例題：
%     Xr = [1 2 3 4];
%     X = hilbert(Xr)
% は、X=[1+1i 2-1i 3-1i 4+1i] を作成します。これは、Xi = imag(X)=[1 -1 
% -1 1] が、Xr のHilbert 変換で、Xr = real(X)=[1 2 3 4] となります。
% fft(X)=[10 -4+4i -2 0] の後半分はゼロになることに注意してください。
% また、fft(X) の DC 成分と Nyquist 要素は、それぞれ、10 と -2 の実数に
% なっていることにも注意してください。
%
% 参考： FFT, IFFT.



%   Copyright 1988-2002 The MathWorks, Inc.
