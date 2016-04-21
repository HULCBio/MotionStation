% HEX2DEC   16進数文字列を10進数整数に変換
% 
% HEX2DEC(H) は、16進文字列 H を解釈し、等価な10進数を出力します。
% 
% H がキャラクタ配列、またはセル配列の場合、各々の行は16進数の文字列と
% して解釈されます。
%
% 例題
% 
%     hex2dec('12B') と hex2dec('12b') は、共に299を出力します。
%
% 参考：DEC2HEX, HEX2NUM, BIN2DEC, BASE2DEC.


%   Author: L. Shure, Revised: 12-23-91, CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 
