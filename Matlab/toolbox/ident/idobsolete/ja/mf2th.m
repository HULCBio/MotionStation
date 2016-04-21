% MF2TH  ユーザ定義のモデル構造から THETA フォーマットを作成
% 
%       TH = MF2TH(MODEL, CD, PARVAL, AUX, LAMBDA, T)
%
%   TH: 結果のモデル行列(THETAフォーマット)
%
%   MODEL  : ユーザ記述の M ファイル名として指定されたモデル構造、つぎの
%            形式の M ファイルです。
% 
%                [a, b, c, d, k, x0] = username(parameters, T, AUX)
% 
%            このとき、MODEL = 'username' となります。フォーマットの詳細
%            は、SSMODELを参照してください。
%   CD     : 'username' で定義されたモデルが、負のサンプル時間Tをもつ連
%            続時間モデルの場合、CD = 'c'。そうでなければ、CD  = 'd'。
%   PARVAL : 自由パラメータの値
%   AUX    : ユーザ記述Mファイルの補助的パラメータの値
%   LAMBDA : イノベーションの共分散行列
%   T      : データのサンプリング周期(常に正の値)
%
% デフォルト値 : AUX = []; T = 1; LAMBDA = 単位行列
%
% 参考:    MS2TH, PEM, THETA

%   Copyright 1986-2001 The MathWorks, Inc.
