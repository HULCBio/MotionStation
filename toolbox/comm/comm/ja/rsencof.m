% RSENCOF   リードソロモン符号を使ってASCIIファイルを符号化
%
% RSENCOF(FILE_IN, FILE_OUT) は、(127, 117) のリードソロモン符号を使用
% して、ASCII ファイル FILE_IN を符号化します。この符号の誤り訂正能力は、
% 各ブロックにつき 5 です。符号は、FILE_OUT に書き出されます。FILE_IN と
% FILE_OUT は、共に文字列変数です。
% 
% RSENCOF(FILE_IN, FILE_OUT, ERR_COR) は、(127, 127 - 2*ERR_COR) リード
% ソロモン符号を使用して、ASCII ファイル FILE_IN を符号化します。誤り
% 訂正能力は ERR_COR です。
%
% 参考： RSDECOF.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
