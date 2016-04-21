% FFT2   2次元高速フーリエ変換
% 
% FFT2(X)は、行列Xの2次元フーリエ変換を出力します。Xがベクトルの場合、
% 結果は同じ向きのベクトルになります。
%
% FFT2(X,MROWS,NCOLS)は、変換の前にXにゼロを加えて、MROWS行NCOLS列の行列
% を作成します。
%
% 参考 FFT, FFTN, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.

%   J.N. Little 12-18-85
%   Revised 4-15-87 JNL
%   Revised 5-3-90 CRD
%   Copyright 1984-2002 The MathWorks, Inc. 
