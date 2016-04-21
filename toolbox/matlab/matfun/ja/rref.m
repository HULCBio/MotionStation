% RREF   行の階段型への変換
% 
% R = RREF(A) は、A の行の階段型を出力します。
%
% [R,jb] = RREF(A) は、つぎのようなベクトル jb も出力します。
% r = length(jb) は、A のランクに関するアルゴリズムのアイデアになっています。
% x(jb) は、線形システム Ax = b の境界変数です。A(:,jb) は、A の範囲に対する
% 基底です。R(1:r,jb) は、r 行 r 列の単位行列です。
%
% [R,jb] = RREF(A,TOL) は、ランクの判定で、与えられた許容誤差を使います。
% 
% 丸め誤差により、このアルゴリズムは、RANK、ORTH、NULL から求まるランクと
% 異なる値を計算することがあります。
%
% 参考：RREFMOVIE, RANK, ORTH, NULL, QR, SVD.

%   CBM, 11/24/85, 1/29/90, 7/12/92.
%   Copyright 1984-2004 The MathWorks, Inc. 

