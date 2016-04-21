% DEC2HEX   10進数整数を16進数文字列に変換
% 
% DEC2HEX(D) は、10進整数 D の16進数表現を、文字列として出力します。
% D は、2^52より小さい非負整数でなければなりません。
%
% DEC2HEX(D,N) は、少なくとも N 桁での16進数表現を生成します。
%
% 例題
% 
%     dec2hex(2748) は、'ABC' を出力します。
%    
% 参考：HEX2DEC, HEX2NUM, DEC2BIN, DEC2BASE.


%   Author: L. Shure
%   Revised by: CMT 1-22-95
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:06:45 $
