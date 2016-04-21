% ARXDATA は、多変数 SISO IDPOLY モデル用の ARX 多項式を出力します。
%
%   [A,B] = ARXDATA(M)
%
%   M : IDPOLY モデルオブジェクト。help IDPOLY を参照。
%
%   A, B : 対応する ARX 多項式
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%
% [A,B,dA,dB] = ARXDATA(M) を使って、A と B の標準偏差、dA と dB を計算
% します。
%
% 参考： IDARX, IDPOLY, ARX

%   L. Ljung 10-2-90,3-13-93


%   Copyright 1986-2001 The MathWorks, Inc.
