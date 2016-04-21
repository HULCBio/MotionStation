% MULERR は、乗法的誤差周波数応答を計算します。
%
% [CG,PH] = MULERR(A0,B0,C0,D0,A,B,C,D,W,OPT) は、2つのモデル (A0,B0,C0,D0) 
% と (A,B,C,D) の間の乗法的誤差周波数応答を計算します。オプション入力 "opt" 
% は、計算方法を設定するものです。
%
%          OPT = 1, 特異値
%          OPT = 2, 特性ゲイン根軌跡
%

% Copyright 1988-2002 The MathWorks, Inc. 
