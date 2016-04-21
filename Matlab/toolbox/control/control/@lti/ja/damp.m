% DAMP   LTIモデルの極に関する固有振動数と減衰比
%
% [Wn,Z] = DAMP(SYS) は、LTIモデル SYS の固有振動数と減衰比のベクトル 
% Wn と Z を出力します。離散時間モデルに対して、固有値 lambda に関する
% 等価な s -平面の固有振動数と減衰比は、
%            
%    Wn = abs(log(lambda))/Ts ,   Z = -cos(angle(log(lambda))) 
%
% サンプル時間 Ts が定義されないと、Wn と Z は、空行列です。
%
% [Wn,Z,P] = DAMP(SYS) は、SYS の極 P も出力します。
%
% 左辺の出力引数を省略した場合、DAMP は極とそれに関する固有振動数と減衰比
% をテーブルにしてモニタに出力します。極は周波数の順にソートされます。
% 
% 参考 : POLE, ESORT, DSORT, PZMAP, ZERO.


%   J.N. Little 10-11-85
%   Revised 3-12-87 JNL
%   Revised 7-23-90 Clay M. Thompson
%   Revised 6-25-96 Pascal Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
