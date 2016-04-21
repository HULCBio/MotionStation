% SUBSREF は、xPC スコープオブジェクトの中を参照します。
% 
% つぎのシンタックスで使用できます。
% 
%   XPCSCOPEOBJ.METHOD(ARGS)
% 
% これは、METHOD(XPCSCOPEOBJ, ARGS) と等価です。また、XPCSCOPEOBJ.PROPERTY
% は、妥当なプロパティ値を出力します。そして、GET(XPCSCOPEOBJ,' PROPERTY')
% と等価になります。また、XPCSCOPEOBJ(INDICES).METHOD(ARGS) と XPCSCOPEOBJ
% (INDICES).PROPERTY を使用することも可能です。他の使用は許されません。
% 
% これは、直接、コールすることを目的としていない、プライベート関数です。
% 
% 参考： SUBSASGN.

%   Copyright 1994-2002 The MathWorks, Inc.
