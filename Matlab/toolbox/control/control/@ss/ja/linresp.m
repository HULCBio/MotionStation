% LINRESP   LTIモデルの時間応答シミュレーション
%
% [Y,T,X] = LINRESP(SYS,TS,U,T,X0) は、初期状態 X0 で、入力 U と T の 
% LTIモデル SYS の時間応答をシミュレーションします。TS は SYS のサンプル
% 時間で、T は出力時間のベクトルです。
%
% [Y,T,X] = LINRESP(SYS,TS,U,T,X0,INTERPRULE)は、連続時間信号に対して、
% サンプル間の内挿ルール(ZOH または FOH)を明示的に設定します。デフォルト
% は、信号が2つの連続するサンプル間で、振幅の全体でのレンジの75 %よりも
% 大きくなる場合を除いて、FOH です。
%
% 関数 LSIM でコールする低水準ユーティリティ


%   Author: P. Gahinet, 4-98
%   Copyright 1986-2002 The MathWorks, Inc. 
