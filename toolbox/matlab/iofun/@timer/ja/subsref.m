% SUBSREF   timer オブジェクト内のサブスクリプトの参照
%
% OBJ(I)  は、サブスクリプトベクトル I で指定された OBJ の要素から
% フォーマットされた配列です。
%
% OBJ.PROPERTY は、timer オブジェクト OBJ に対する PROPERTY の
% プロパティベクトルを出力します。
%
% timer オブジェクトでサポートされるシンタックス:
%
%   正しくない記法:                Get 記法と等価な方法:
%   ===============                =====================
%   obj.Tag                        get(obj,'Tag')
%   obj(1).Tag                     get(obj(1),'Tag')
%   obj(1:4).Tag                   get(obj(1:4), 'Tag')
%   obj(1)                         
%
% 参考 : TIMER/GET.


%    RDD 12-07-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2003/04/18 16:33:10 $
