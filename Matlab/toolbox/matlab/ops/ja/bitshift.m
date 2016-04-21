%BITSHIFT ビット単位のシフト
% C = BITSHIFT(A,K) は、A の値を K ビットシフトした値を出力します。
% A は、通常、符号なし整数です。K ビットシフトすることは、2^K の乗算を
% 行うことと同じです。K は負の値になることができ、これは、右へのシフト、
% 2^ABS(K) の除算、整数に丸めることに相当します。シフトにより C が、
% A の符号なし整数クラスのビット数オーバーフローする場合、オーバーフロー
% したビットは落とされます。
% A が倍精度の変数の場合、その値は、0 から BITMAX の間の整数である
% 必要があり、オーバーフローは、53 ビットを超えると起こります。
%
% C = BITSHIFT(A,K,N) は、A が倍精度の場合、N ビットオバーフローを
% 起こし、オーバーフローしたビットは落とされます。N は、53 以下で
% なければなりません。N　として、BITSHIFT(A,K,8) または 2 の他の累乗
% を使用するのではなく、A としてBITSHIFT(UINT8(A),K) または 適当な
% 符号なし整数のクラスを使用することを検討してください。
%
% 例題:
% すべての非ゼロビットがオーバーフローするまで、符号なし 16 ビット値の
% ビットを繰り返し左にシフトします。経過をバイナリで追跡してください。
%
%    a = intmax('uint16');
%    disp(sprintf('Initial uint16 value %5d is %16s in binary', ...
%       a,dec2bin(a)))
%    for i = 1:16
%       a = bitshift(a,1);
%       disp(sprintf('Shifted uint16 value %5d is %16s in binary',...
%          a,dec2bin(a)))
%    end
%
% 倍精度変数で同じ実験を繰り返します。
%
%    a = double(intmax('uint16'));
%    disp(sprintf('Initial double value %5d is %16s in binary', ...
%       a,dec2bin(a)))
%    for i = 1:16
%       a = bitshift(a,1,16);
%       disp(sprintf('Shifted double value %5d is %16s in binary',...
%          a,dec2bin(a)))
%    end
%
% 倍精度変数をそのデフォルトの 53 ビットでオーバーフローさせることとの
% 違いに注意してください。簡単のために、毎回 3 ずつシフトします。
%
%    a = double(intmax('uint16'));
%    disp(sprintf('Initial double value %16.0f is %53s in binary', ...
%       a,dec2bin(a)))
%    for i = 1:18
%       a = bitshift(a,3);
%       disp(sprintf('Shifted double value %16.0f is %53s in binary',...
%          a,dec2bin(a)))
%    end
%
% 参考 BITAND, BITOR, BITXOR, BITCMP, BITSET, BITGET, BITMAX, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
