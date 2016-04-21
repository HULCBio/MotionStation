% ALLCHILD   すべてのオブジェクトの子オブジェクトの取得
% 
% ChildList = ALLCHILD(HandleList) は、各ハンドルに対して、すべての子
% オブジェクト(隠されているハンドルを含みます)のリストを出力します。
% HandleList が単一の要素の場合は、ベクトルに出力されます。他の場合は、
% セル配列に出力されます。
%
% たとえば、get(gca,'children') と allchild(gca) を実行してみてください。
%
% 参考：GET, FINDALL.


%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:07:39 $
