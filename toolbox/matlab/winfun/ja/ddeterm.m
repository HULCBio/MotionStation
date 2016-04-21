% DDETERM DDE通信の終了
% 
% DDETERMは、DDE通信を確立するDDEINITから得たチャンネルハンドルを引数と
% して与えます。 
%
% rc = DDETERM(channel)
%
% rc      返り値: 0は失敗、1は成功を意味します。
% channel DDEINITからの通信チャンネル
%
% たとえば、つぎのようにDDE通信を終了させます。
% 
%      rc = ddeterm(channel);
%
% 参考：DDEINIT, DDEEXEC, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:09:46 $
%   Built-in function.
