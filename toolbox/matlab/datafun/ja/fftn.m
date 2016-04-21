% FFTN   N次元高速フーリエ変換
% 
% FFTN(X)は、N次元配列XのN次元の離散フーリエ変換を出力します。Xがベクト
% ルの場合、出力は同じ向きのベクトルになります。
% 
% FFTN(X,SIZ)は、変換前に、変換後のサイズベクトルがSIZになるように、Xに
% ゼロを加えます。SIZの各要素が、Xの対応した次元よりも小さい場合、Xはそ
% の次元で打ち切られます。
%
% 参考 FFT, FFT2, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.

%   Copyright 1984-2002 The MathWorks, Inc. 
