% LINRESP   LTIモデルの時間応答シミュレーション
%
% [Y,T,X] = LINRESP(SYS,TS,U,T,X0) は、入力 U と初期状態 X0 で、LTIモデル
% SYS の時間応答をシミュレーションします。TS は SYS のサンプル時間で、
% T は出力時間のベクトルです。
%
% LSIM でコールされる低水準ユーティリティ


%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
