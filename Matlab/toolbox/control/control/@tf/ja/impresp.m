% IMPRESP   単一のLTIモデルのインパルス応答を計算
%
% [Y,T,X] = IMPRESP(SYS,TS,T,T0) は、サンプル時間 TS のLTIモデル SYS 
% の出力時間 T(t = 0で開始)でのインパルス応答を計算します。T0 > 0の場合、
% t = 0 から t = T0 までの応答は切り捨てます。 
%
% IMPULSE でコールする低水準ユーテリティ


%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
