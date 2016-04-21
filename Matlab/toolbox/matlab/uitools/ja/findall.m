% FINDALL   すべてのオブジェクトの検索
% 
% ObjList = FINDALL(HandleList) は、与えられた Handle 以下のすべての
% オブジェクトのリストを出力します。FINDOBJを使用して、HandleVisibility 
% が 'off' に設定されているすべてのオブジェクトが検索されます。FINDALL 
% は、FINDOBJ の呼び出しと全く同様に呼び出されます。たとえば、
% ObjList = findall(HandleList,Param1,Val1,Param2,Val2,...) です。
%
% たとえば、つぎのように実行してみてください。
%
%   plot(1:10)
%   xlabel xlab
%   a = findall(gcf)
%   b = findobj(gcf)
%   c = findall(b,'Type','text')  % xlabelのハンドル番号を2回出力します。
%   d = findobj(b,'Type','text')  % xlabelのハンドル番号は検索できません。
%
% 参考：ALLCHILD, FINDOBJ.


%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:08:01 $
