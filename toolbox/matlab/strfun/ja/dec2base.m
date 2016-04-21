% DEC2BASE   10進数を基底Bの文字列に変換
% 
% DEC2BASE(D,B) は、D を基底 B の文字列として表現して出力します。D は、
% 2^52より小さい非負整数配列で、B は2と36の間の整数でなければなりません。
%
% DEC2BASE(D,B,N) は、少なくとも N 桁での表現を生成します。
%
% 例題
% 
%     dec2base(23,3) は、'212'を出力します。
%     dec2base(23,3,5) は、'00212'を出力します。
%
% 参考：BASE2DEC, DEC2HEX, DEC2BIN.


%   Copyright 1984-2002 The MathWorks, Inc. 
