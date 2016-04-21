% RSDECOF   リードソロモン符号を使って符号化されたASCIIファイルを復号
%
% RSDECOF(FILE_IN, FILE_OUT)は、(127, 117) リードソロモン符号を使って、
% ASCIIファイルFILE_INを復号します。この符号の誤り訂正能力は、各ブロック
% について 5 です。復号メッセージは FILE_OUT に書き出されます。FILE_IN　
% と FILE_OUTは、共に文字列変数です。FILE_INは、RSENCOFにより処理した
% 出力でなければなりません。
% 
% RSDECOF(FILE_IN, FILE_OUT, ERR_COR)は、(127, 127-2*ERR_COR) リード
% ソロモン符号を使って、ASCIIファイルFILE_INを復号します。誤り訂正能力は、
% ERR_COR です。
%
% 参考： RSENCOF.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $