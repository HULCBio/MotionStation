% RARMAX は、ARMAX モデルの逐次推定を行います。
% 
%   [THM,YHAT] =RARMAX(Z,NN,adm,adg)
%
%   Z  : 出力 - 入力データ z = [y u] (単入力のみ!)
%   NN : NN = [na nb nc nk]、ARMAX 入力 - 出力モデルの次数と遅れ(ARMAX 
%        を参照)
%
%   adm : 適応メカニズム、 adg: 適応ゲイン
%      adm='ff', adg=lam : 忘却ファクタ lam を使った忘却ファクタアルゴリ
%           ズム
%      adm='kf', adg=R1  : 時間ステップ毎に変化するパラメータの共分散行
%           列 R1 を使った Kalman フィルタアルゴリズム
%      adm='ng', adg=gam : ゲイン gam を使った正規化された勾配アルゴリズ
%           ム
%      adm='ug', adg=gam : ゲイン gam を使った正規化していない勾配アルゴ
%           リズム
%   THM : 推定結果。行 k は、時刻 k までのデータに対応する"アルファベッ
%         ト順の"推定パラメータです。
%   YHAT: 出力の予測値。行 k は、時刻 k に対応しています。パラメータ(TH0) 
%         と "P-行列"(P0) の初期値をつぎのように使います。
%
%    [THM,YHAT,P] = RARMAX(Z,NN,adm,adg,TH0,P0)
% 
% 補助データべクトル phi と psi の初期値と最終値は、つぎのステートメント
% で、得られます。
% 
%    [THM,YHAT,P,phi,psi] = RARMAX(Z,NN,adm,adg,TH0,P0,phi0,psi0).
%
% 参考： RARX, ROE, RBJ, RPEM and RPLR.



%   Copyright 1986-2001 The MathWorks, Inc.
