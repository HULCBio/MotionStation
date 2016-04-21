% MLOCK   M-ファイルを消去するのを防ぎます
% 
% MLOCK は、メモリ内でカレントに実行しているM-ファイルをロックし、
% それに続くCLEARコマンドで消されないようにします。
%
% M-ファイルを通常の消去可能な状態に戻すには、MUNLOCK または
% MUNLOCK(FUN) を使ってください。
%
% メモリ内にM-ファイルをロックすることは、ファイル内で定義されている
% PERSISTENT変数を再度初期化することを防ぎます。
% 
% 参考：MUNLOCK, MISLOCKED, PERSISTENT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:17 $
%   Built-in function.

