%BITMAX 最大の浮動小数点整数
% BITMAX は、最大の符号なし倍精度浮動小数点整数を出力します。 
% すべてのビットが設定されるとき、この値 (2^53-1) になります。
%
% 整数値の倍精度変数ではなく、ビット操作に符号なし整数を使用し、
% BITMAX を INTMAX で置き換えてください。
%
% 例題:
% 最大の浮動小数点整数と最大の 32 ビット符号なし整数を
% 異なる形式で表示します。
%      >> format long e
%      >> bitmax
%      ans =
%          9.007199254740991e+015
%      >> intmax('uint32')
%      ans =
%        4294967295
%      >> format hex
%      >> bitmax
%      ans =
%         433fffffffffffff
%      >> intmax('uint32')
%      ans =
%         ffffffff
%
% 注意: BITMAX の最後の 13 hex digits は、バイナリ表現の仮数で
% 52 個の 1 (すべて 1) に相当する、"f" です。最初の 3 hex digits は、
% sign ビット 0 と 11 ビットのバイナリでバイアスされた指数 10000110011 
% (10進数の 1075) に相当し、実際の指数は、(1075-1023)=52 です。こうして、
% BITMAX のバイナリ値は、52 個の 1 が続く 1.111...111x2^52, すなわち、
% 2^53-1 です。
%
% 参考 INTMAX, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, BITSET, BITGET.

%   Copyright 1984-2004 The MathWorks, Inc. 
