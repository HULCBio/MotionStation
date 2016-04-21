% DFTMTX   ガロア体の離散フーリエ変換行列
%
% DFTMTX(ALPH) は、列ベクトルの積がスカラ ALPH のGFに対するベクトルの
% 離散フーリエ変換となるN行N列の行列です。N は、m がGFオブジェクト 
% ALPH のビット数として、2^m-1 によって与えられる DFT の大きさです。
% ALPH は、次数 N として、1,2 ... ,N-1 となるすべての K に対して、
% ALPH^N = 1 と ALPH^K ~= 1 であるN番目の原始根をもつと仮定されます。
% DFTMTX の i,j 番目の要素は、ALPH^((i-1)*(j-1)) です。
%
% 逆離散フーリエ変換行列は、DFTMTX(1/ALPH) となります。
%
% 参考 : FFT.


%    Copyright 1996-2002 The MathWorks, Inc.
