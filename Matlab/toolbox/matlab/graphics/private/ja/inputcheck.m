% INPUTCHECK   PRINTの入力引数の検証
% 入力引数を解釈し、それに従ってPrintJobオブジェクトの状態をアップデートします。
% 正常にPRINTに渡されるデバイスとオプションのリストに対して、PrintJobオブジェク
% トとセル配列を出力します。不正な引数が見つかるとエラーになります。 
%
% 例題:
% 
%    [pj、dev、opt] = INPUTCHECK( pj、... ); 
%
% 参考：PRINT, TABLE, VALIDATE.

%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:33 $
%   Copyright 1984-2002 The MathWorks, Inc. 
