% SUBSASGN   timer オブジェクト内にサブスクリプトの割り当て
%
% OBJ(I) = B は、サブスクリプトベクトル I で指定された OBJ の要素内に
% B の値を割り当てます。B は、I の要素と同じ数かスカラでなければなり
% ません。
% 
% OBJ(I).PROPERTY = B は、timer オブジェクト OBJ のプロパティ 
% PROPERTY に B の値を割り当てます。
%
% timer オブジェクトでサポートされるシンタックス:
%
%    正しくない記法:                Set 記法と等価な方法:
%    ==============                 =====================
%    obj.Tag='sydney';              set(obj, 'Tag', 'sydney');
%    obj(1).Tag='sydney';           set(obj(1), 'Tag', 'sydney');
%    obj(1:4).Tag='sydney';         set(obj(1:4), 'Tag', 'sydney');
%    obj(1)=obj(2);               
%    obj(2)=[];
%
% 参考 : TIMER/SET.


%    RDD 12-7-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2003/04/18 16:33:09 $
