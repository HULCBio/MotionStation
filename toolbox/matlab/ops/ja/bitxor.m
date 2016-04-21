%BITXOR ビット単位の排他的論理和
% C = BITXOR(A,B) は、2つの引数 A と B のビット単位の排他的論理和を出力します。
% A と B は共に、符号なし整数でなければなりません。
%
% 例題:
%      Create a truth table:
%      A = uint8([0 1; 0 1])
%      B = uint8([0 0; 1 1])
%      TT = bitxor(A,B)
%
% 参考 BITOR, BITAND, BITCMP, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
