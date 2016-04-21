%BITCMP 補数ビット
% C = BITCMP(A,N) は、Aのビット単位の補数を、N ビットの符号なし整数
% として出力します。A は、N より大きいビットセット、すなわち、2^N-1
% より大きい値をもちません。 N が A の符号なし整数のクラスのビット数
% である場合、たとえば、N が UINT32 に対して 32 の場合、A は、0 と 
% INTMAX(CLASS(A)) の間の値をもちます。
%
% 例題:
%      a = uint16(intmax('uint8'))
%      bitcmp(a,8)
%
% 参考 BITAND, BITOR, BITXOR, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
