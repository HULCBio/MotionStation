% IFFT2   2次元逆離散フーリエ変換
% 
% IFFT2(F)は、行列Fの2次元逆離散フーリエ変換を行います。Fがベクトルの場
% 合、結果は、同じ向きのベクトルになります。
%
% IFFT2(F,MROWS,NCOLS)は、変換の前にFにゼロを加えて、MROWS行NCOLS列の行
% 列を作成します。
%
% IFFT2(..., 'symmetric') では、出力が実数になるように、2 次元で
% F を共役対称として取り扱います。 このオプションは丸め誤差のため、
% F が 厳密に共役対称でない場合、有効です。この対称性に関する特定の
% 数学的な定義については、リファレンスページを参照してください。
%
% IFFT2(..., 'nonsymmetric') では、IFFT2 は、F の対称性について何も
% 仮定しません。
%
% 参考 FFT, FFT2, FFTN, FFTSHIFT, FFTW, IFFT, IFFN.

%   J.N. Little 12-18-85
%   Revised 4-15-87 JNL
%   Revised 5-3-90 CRD
%   Copyright 1984-2002 The MathWorks, Inc. 
