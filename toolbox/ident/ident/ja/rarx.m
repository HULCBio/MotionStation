% RARX は、ARX モデルの逐次推定を行います。
% 
%   [THM,YHAT] = RARX(Z,NN,adm,adg)
%
%   z : IDDATA オブジェクト、または、出力 - 入力データ行列 z = [y u]
%       このルーチンは、単出力多入力データに対応しています。
%   NN : NN = [na nb nk]、ARX モデルの次数と遅れ(ARX を参照)
%
%   adm: 適応メカニズム、 adg: 適応ゲイン
%      adm='ff', adg=lam : 忘却ファクタ lam を使った忘却ファクタアルゴリ
%                          ズム
%      adm='kf', adg=R1  : 時間ステップ毎に変化するパラメータの共分散行
%                          列 R1 を使った Kalman フィルタアルゴリズム
%      adm='ng', adg=gam : ゲイン gam を使った正規化された勾配アルゴリズ
%                          ム
%      adm='ug', adg=gam : ゲイン gam を使った正規化していない勾配アルゴ
%                          リズム
%   THM  : 推定結果。行 k は、時刻 k までのデータに対応する"アルファベッ
%          ト順の"推定パラメータです。
%   YHAT : 出力の予測値。行 k は、時刻 k に対応しています。パラメータ
%          (TH0) と "P-行列"(P0) の初期値をつぎのように使います。
%
%    [THM,YHAT,P] = RARX(Z,NN,adm,adg,TH0,P0)
% 
% 補助データべクトル phi と psi の初期値と最終値は、つぎのステートメント
% で、得られます。
% 
%    [THM,YHAT,P,phi]=RARX(Z,NN,adm,adg,TH0,P0,phi0).
%
% 参考： RARMAX, ROE, RBJ, RPEM and RPLR.



%   Copyright 1986-2001 The MathWorks, Inc.
