% ADDSCOPE は、スコープをカレントシミュレーションに加えます。
% 
% ADDSCOPE(XPCOBJ, SCOPETYPE, SCOPEID) は、タイプが SCOPETYPE のスコー プ
% オブジェクトをXPCOBJ で表されるターゲットに付加し、それに、識別子  SCOP-
% EID を与えます。SCOPETYPE と SCOPEID は、オプションで、SCOPEID  が設定さ
% れている場合、SCOPETYPE も設定されていなければなりません。SC OPETYPE は
% 'host'、または、'target' のいずれかです。何も設定していない場合、SCOPE-
% TYPE は、'host'に設定されます。そして、SCOPEID を、そ のつぎの利用可能な
% インデックスに設定します。既に存在している SCOPEID  を設定するとエラーに
% なります。
% 
% ADDSCOPE は、たとえば、SUOBJ=ADDSCOPE のように明示的に戻り値が要求される
% か、XPCOBJ を更新する場合に、スコープオブジェクトを出力します。
% 
% 参考：REMSCOPE, GETSCOPE

%   Copyright 1994-2002 The MathWorks, Inc.
