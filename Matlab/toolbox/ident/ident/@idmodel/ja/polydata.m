% POLYDATA は、与えられたモデルに関連した多項式を計算します。
% 
%   [A,B,C,D,F]=POLYDATA(MODEL)
%
% MODEL は、IDMODEL オブジェクトで表されたモデルです。
%
% A,B,C,D, F は、一般的な入力 - 出力モデルの対応する多項式を表すものとし
% て出力されます。A, C, D は行ベクトルで、B と F は入力と同じ行数をもっ
% ています。
%
%   [A,B,C,D,F,dA,dB,dC,dD,dF] = POLYDATA(MODEL)
% 
% は、推定多項式の標準偏差も出力します。
%
% 参考： IDPOLY



%   Copyright 1986-2001 The MathWorks, Inc.
