% UDECODE は、入力の一様復号化を行います。
% Y = UDECODE(U,N) は、配列 U のデータを、ピーク値+/- 1で、復号化します。
% 入力データタイプは、[0  2^N-1]の範囲で符号付きまたは符号なし整数です。
% 出力データタイプは、倍精度です。オーバフローが生じた場合、入力は飽和し
% ます。
%
% Y = UDECODE(U,N,V) は、ピーク値+/- V をもつデータを復号化します。
%
% Y = UDECODE(U,N,V,'wrap') は、オーバフローが生じた場合、入力を不連続に
% します。
% 
% 参考：   UENCODE, SIGN, FIX, FLOOR, CEIL, ROUND.



%   Copyright 1988-2002 The MathWorks, Inc.
