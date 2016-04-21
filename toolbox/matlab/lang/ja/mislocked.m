% MISLOCKED   消去できないM-ファイルの検出
% 
% MISLOCKED(FUN) は、FUN という関数がメモリ内でロックされていれば1を
% 出力し、そうでなければ0を出力します。ロックされたM-ファイルは、消去
% できません。
%
% MISLOCKED 自身では、カレントに実行中のM-ファイルがロックされていれば
% 1を出力し、そうでなければ0を出力します。
%
% 参考：MLOCK, MUNLOCK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:16 $
%   Built-in function.
