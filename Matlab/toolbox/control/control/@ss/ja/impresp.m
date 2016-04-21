% IMPRESP   単一LTIモデルのインパルス応答
%
% [Y,T,X] = IMPRESP(SYS,TS,T,T0) は、サンプル時間 TS のLTIモデル SYS 
% のインパルス応答を時刻暦 T(スタート時間 t = 0)でのインパルス応答を
% 計算します。 t = 0から t = T0の応答は、T0>0の場合、切り捨てます。
%
% 関数 IMPULSE で、コールする低水準ユーティリティ


%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
