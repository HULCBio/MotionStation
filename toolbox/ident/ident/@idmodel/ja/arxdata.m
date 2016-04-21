% ARXDATA は、多変数 IDARX モデルの ARX 多項式を出力します。
%
%   [A,B] = ARXDATA(M)
%
%   M : IDARX モデルオブジェクト。help IDARX を参照。
%
%   A, B : ny-ny-n と ny-nu-m の行列で、ARX 構造を定義します
%          (ny:出力数、nu:入力数)
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%          A(:,:,k+1) = Ak,  B(:,:,k+1) = Bk
%
% [A,B,dA,dB] = ARXDATA(M) を使って、A と B の標準偏差、dA と dB を計算し
% ます。
%
% 参考： IDARX, ARX

%   L. Ljung 10-2-90,3-13-93


%   Copyright 1986-2001 The MathWorks, Inc.
