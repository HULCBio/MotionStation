%BITGET ビットの取り出し
% C = BITGET(A,BIT) は、A の中の位置 BIT にあるビット値を出力します。
% A は、符号なし整数で、BIT は 1 と A の符号なし整数のクラスのビット数
% (UINT32では32)の間の値でなければなりません。
%
% 例題:
%    INTMAX がすべてのビットを 1 に設定することを示します。
%
%    a = intmax('uint8')
%    if all(bitget(a,1:8)), disp('All the bits have value 1.'), end
%
% 参考 BITSET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2002 The MathWorks, Inc. 
