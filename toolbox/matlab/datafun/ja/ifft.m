% IFFT   逆離散フーリエ変換
% 
% IFFT(X)は、Xの逆離散フーリエ変換を行います。
%
% IFFT(X,N)は、N点の逆離散フーリエ変換を行います。
%
% IFFT(X,[],DIM)、または、IFFT(X,N,DIM)は、次元DIMのXの逆離散フーリエ
% 変換を出力します。
%
% IFFT(..., 'symmetric') では、IFFT は、アクティブな次元で
% 共役対称として F を取り扱います。このオプションは丸め誤差のため、
% F が 厳密に共役対称でない場合、有効です。この対称性に関する特定の
% 数学的な定義については、リファレンスページを参照してください。
%
% IFFT(..., 'nonsymmetric') では、IFFT は、F の対称性について何も
% 仮定しません。
%
% 参考 FFT, FFT2, FFTN, FFTSHIFT, FFTW, IFFT2, IFFTN.


%   Copyright 1984-2002 The MathWorks, Inc. 
