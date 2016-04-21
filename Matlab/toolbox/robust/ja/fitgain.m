% FITGAIN は、位相情報なしに周波数応答曲線の近似(PSD 法)
%
% [SS_] = FITGAIN(MAG,W,ORD,WT,FLAG)、または、
% [A,B,C,D] = FITGAIN(MAG,W,ORD,WT,FLAG) は、連続システムのゲイン曲線 
% "MAG" の"安定な"状態空間実現を作成します。
%
%    入力：
%               mag ---- ゲインの絶対値からなる配列
%               w   ---- "mag"を計算する周波数 (rad/sec)
%               ord ---- 実現のサイズ
%    オプション：
%               wt  ---- 曲線近似の重み付け(デフォルト = ones(w))
%               flag --- Bode 線図を表示(デフォルト), 0: Bode 線図を表示
%                        しない
%
%    出力： (a,b,c,d) ---- "MAG" の安定実現
%
%  アルゴリズムは、つぎの3ステップから構成されています。
%                         2
%                   |G(s)|   = G(s) * G(-s)
%    ステップ1：G(s) の PSD を計算、すなわち、PSD = |G(s)|^2 を実行
%    ステップ2：MATLAB 関数 "invfreqs.m"を使って、PSD を有理関数で近似し
%               ます。
%    ステップ3：実現の中の安定、最小位相部を抽出
%                          (終了 !!)

% Copyright 1988-2002 The MathWorks, Inc. 
