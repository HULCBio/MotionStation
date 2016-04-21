% GETSCOPE は、xPC スコープオブジェクトを取得します。
% 
% GETSCOPE(XPCOBJ, ID) は、XPCOBJ で表されるターゲットから識別子 ID をもつ
% xPC スコープオブジェクトを出力します。存在していないスコープをアクセスし
% ようとするとエラーになります。存在しているスコープのリストは、GET(XPCOBJ,
% 'SCOPES') を通して得られます。ID はベクトルでも構いません。
% 
% この場合、その ID のスコープオブジェクトがすべて、存在していなければなり
% ません。
% 
% 参考： ADDSCOPE, REMSCOPE

%   Copyright 1994-2002 The MathWorks, Inc.
