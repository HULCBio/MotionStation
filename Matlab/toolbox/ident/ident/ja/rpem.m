% RPEM は、一般モデルの逐次推定を計算
% 
%   [THM,YHAT] = RPEM(Z,NN,adm,adg)
%
%   z  : IDDATA オブジェクト、または、出力 - 入力データ行列 z = [y u].
%        ルーチンは、多入力単出力データのみを扱います。
%   NN : NN = [na nb nc nd nf nk]、一般入力 - 出力モデルの次数と遅れ(PEM
%        を参照)
%
%   adm : 適応メカニズム、 adg: 適応ゲイン
%    adm='ff', adg=lam : 忘却ファクタ lam を使った忘却ファクタアルゴリズ
%                        ム
%    adm='kf', adg=R1  : 時間ステップ毎に変化するパラメータの共分散行列 
%                        R1 を使った Kalman フィルタアルゴリズム
%    adm='ng', adg=gam : ゲイン gam を使った正規化された勾配アルゴリズム
% 
%    adm='ug', adg=gam : ゲイン gam を使った正規化していない勾配アルゴリ
%                        ズム
%   THM  : 推定結果。行 k は、時刻 k までのデータに対応する"アルファベッ
%          ト順の"推定パラメータです。
%   YHAT : 出力の予測値。行 k は、時刻 k に対応しています。パラメータ
%          (TH0) と "P-行列"(P0) の初期値をつぎのように使います。
%
%     [THM,YHAT,P] = RPEM(Z,NN,adm,adg,TH0,P0)
%
% 補助データべクトル phi と psi の初期値と最終値は、つぎのステートメント
% で、得られます。
% 
%         [THM,YHAT,P,phi,psi]=RPEM(Z,NN,adm,adg,TH0,P0,phi0,psi0).
%
% 参考： RARMAX, RARX, ROE, RBJ AND RPLR.



%   Copyright 1986-2001 The MathWorks, Inc.
