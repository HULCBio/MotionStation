% DAMP   LTI モデルの極に関する固有振動数と減衰比を計算
%
%
% [Wn,Z] = DAMP(SYS) は、LTI モデル SYS の固有振動数と減衰比のベクトルWn と
% Z を出力します。離散時間モデルに対して、固有値 lambda に関する等価な
% s -平面の固有振動数と減衰比は、
%
% Wn = abs(log(lambda))/Ts ,   Z = -cos(angle(log(lambda)))
%
% サンプル時間 Ts が定義されないと、Wn と Z は、空ベクトルです。
%
% [Wn,Z,P] = DAMP(SYS) は、SYS の極 P も出力します。
%
% 左辺の出力引数を省略した場合、DAMP は極とそれに関する固有振動数と減衰比を
% テーブルにしてモニタに出力します。極は周波数の順にソートされます。
%
% 参考 : POLE, ESORT, DSORT, PZMAP, ZERO.


% Copyright 1986-2002 The MathWorks, Inc.
