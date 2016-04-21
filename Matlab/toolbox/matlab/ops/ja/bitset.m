%BITSET ビットの設定
% C = BITSET(A,BIT) は、A 内のビットの位置 BIT を 1(on) に設定します。
% A は、符号なし整数で、BIT は、1 と A　の符号なし整数クラスのビットの長さ
% ( UINT32 では 32 ) の間の値でなければなりません。
%
% C = BITSET(A,BIT,V) は、位置 BIT にあるビットを値 V に設定します。 
% V は 0 または 1 のいずれかでなければなりません。
%
% 例題:
%  最大の UINT32 の値から 2 の累乗を繰り返し引きます。
%
%    a = intmax('uint32')
%    for i = 1:32, a = bitset(a,32-i+1,0), end
%
% 参考 BITGET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
