% MUNLOCK   M-ファイルを消去可能にします。
% 
% MUNLOCK(FUN) は、CLEAR コマンドで消去できるように、メモリ内の FUN と
% いうM-ファイルをアンロックします。M-ファイルは、デフォルトでは、
% M-ファイルの変更を可能にするためにアンロックされています。MUNLOCK の
% 呼び出しは、コマンド MLOCK を使ってロックされているM-ファイルを
% アンロックするためだけに必要です。
%
% MUNLOCK によって、現在実行中のM-ファイルはアンロックされています。
%
% 参考：MLOCK, MISLOCKED.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:18 $
%   Built-in function.
