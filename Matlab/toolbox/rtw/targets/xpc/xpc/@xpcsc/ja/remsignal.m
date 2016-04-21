% REMSIGNAL は、xpcsc オブジェクトで表されるスコープから信号を除去します。
% 
% REMSIGNAL(XPCSCOPEOBJ, SIGNALS) は、XPCSCOPEOBJ で表されるスコープから信
% 号(ベクトル)を除去します。信号は、XPC/GETSIGNALID を使って得られるインデ
% ックスで指定します。XPCSCOPEOBJ がベクトルの場合、(除去されるべき)同じ信
% 号が、各スコープの中に存在していなくてはなりません。引数 SIGNALSはオプシ
% ョンで、設定されていない場合は、すべての信号が除去されます。
% 
% 参考： ADDSIGNAL, XPC/GETSIGNALID.

%   Copyright 1994-2002 The MathWorks, Inc.
