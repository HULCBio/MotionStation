% UENCODE は、入力を N ビットで一様量子化、符号化を行います。
% Y = UENCODE(U,N) は、ピーク値 +/- 1で入力値を飽和させている配列 U のデ
% ータを一様に量子化や符号化します。出力は、[0  2^N-1] の範囲に入ります。
% 出力のデータタイプは、必要なビット数の最小数をベースにして決定した8, 
% 16, 32-ビットの符号なし整数です。
%
% Y = UENCODE(U,N,V) は、ピーク値 +/- Vで入力を飽和します。
% 
% Y = UENCODE(U,N,V,'unsigned') は、範囲 [0  2^N-1] で、符号なし整数を出
% 力します。
%
% Y = UENCODE(U,N,V,'signed') は、範囲 [-2^(N-1)  2^(N-1)-1] で、符号付
% き整数を出力します。
%
% 参考：   UDECODE, SIGN, FIX, FLOOR, CEIL, ROUND.



%   Copyright 1988-2002 The MathWorks, Inc.
