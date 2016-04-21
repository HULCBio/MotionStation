% TH2ARX THETA フォーマットモデルをARXモデルに変換
% 
%   [A, B]=TH2ARX(TH)
%
%   TH   : THETA フォーマットで定義されたモデル構造(THETA 参照)
%
%   A, B : ARX 構造を定義する行列:
%
%          y(t) + A1 y(t-1) + .. + An y(t-n) = ...
%                  B0 u(t) + ..+ B1 u(t-1) + .. Bm u(t-m)
%
%          A = [I A1 A2 .. An],  B=[B0 B1 .. Bm]
%
%
% [A, B, dA, dB] = TH2ARX(TH)と実行すると、A, B の標準偏差を dA, dB に出
% 力します。
%
% 参考:    ARX2TH, ARX

%   Copyright 1986-2001 The MathWorks, Inc.
