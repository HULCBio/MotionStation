% FFT  離散フーリエ変換
% 
% FFT(X)は、ベクトルXの離散フーリエ変換(DFT)を出力します。FFT は、行列に
% 対しては列単位で操作を行います。FFTは、N次元配列に対しては、最初に1で
% ない次元に対して操作を行います。
%
% FFT(X,N)は、N点のFFTを出力します。Xの長さがNより小さい場合は、Nになる
% まで後ろに0を加えます。Xの長さがNより大きい場合は、XのNより長い部分は、
% 打ち切られます。
%
% FFT(X,[],DIM)とFFT(X,N,DIM)は、次元DIM上でFFT演算を適用します。
% 
% 長さNの入力ベクトルxに対して、DFTは、つぎの要素をもつ長さNのベクトルX
% になります。
%                  N
%    X(k) =       sum  x(n)*exp(-j*2*pi*(k-1)*(n-1)/N)、1 < =  k < =  N.
%                 n = 1
% 
% 逆DFT(IFFTにより計算される)は、つぎの式で与えられます。
% 
%                  N
%    x(n) = (1/N) sum  X(k)*exp( j*2*pi*(k-1)*(n-1)/N)、1 < =  n < =  N.
%                 k = 1
% 
%
% 参考 FFT2, FFTN, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.


%   Copyright 1984-2002 The MathWorks, Inc. 
