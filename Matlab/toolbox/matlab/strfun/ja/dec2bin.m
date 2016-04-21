% DEC2BIN   10進数整数を2進数文字列に変換
% 
% DEC2BIN(D) は、D の2進数表現を文字列として出力します。D は、2^52より
% 小さい非負整数でなければなりません。 
%
% DEC2BIN(D,N) は、少なくとも N 桁での2進数表現を生成します。
%
% 例題
% 
%   dec2bin(23) は、'10111'を出力します。
%
% 参考：BIN2DEC, DEC2HEX, DEC2BASE.


%   Hans Olsson, hanso@dna.lth.se 3-23-95
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:06:44 $
