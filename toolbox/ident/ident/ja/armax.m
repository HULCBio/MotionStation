% ARMAX	   予測誤差法による ARMAX モデルの推定
%
%   M = ARMAX(Z,[na nb nc nk])  
%   M = ARMAX(Z,'na',na,'nb',nb,'nc',nc,'nk',nk)
%
%   M : 推定された共分散と構造体情報と共に、IDPOLY オブジェクトフォーマ
%       ットで、推定したモデル出力。M の正確なフォーマットは、help IDP-
%       OLY を参照してください。
%
%   Z : IDDATA オブジェクトフォーマットで記述された推定に使用するデータ
%       詳細は、IDDATA を参照。
%
%   [na nb nc nk] は、ARMAX モデルの次数と遅れです。
%
%	   A(q) y(t) = B(q) u(t-nk) + C(q) e(t)
%
% 多入力データの場合、nbとnkは入力チャネル数と同じ長さの行ベクトルです。
%
% 別の表現として、M = ARMAX(Z,Mi) を使うことができます。ここで、Mi は、
% 推定されたモデル、または、IDPOLY で作成されたモデルのどちらかです。最
% 小化は、Mi で与えられたパラメータで初期化されます。
%
% M = ARMAX(Z,nn,Property_1,Value_1, ...., Property_n,Value_n) を使って、
% モデル構造とアルゴリズムに関連したすべてのプロパティを設定できます。プ
% ロパティ名/値の一覧については、HELP IDPOLY、または、IDPROPS ALGORITHM 
% を参照してください。



%   Copyright 1986-2001 The MathWorks, Inc.
