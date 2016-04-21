% TH2POLY 与えられたモデルに対応する多項式の抽出
% 
%       [A, B, C, D, F, LAM, T] = TH2POLY(TH)
%
% TH は、THETA フォーマットで記述されたモデルです(THETA 参照)。
%
% A, B, C, D, F は、一般的な入出力モデルに対応する多項式。
% A, C, D は行ベクトルで、B, F は入力と同じ数の行数をもちます。
% LAM は、雑音源の分散です。
% T は、サンプリング周期です。
% 
% 参考： POLY2TH.

%   Copyright 1986-2001 The MathWorks, Inc.
