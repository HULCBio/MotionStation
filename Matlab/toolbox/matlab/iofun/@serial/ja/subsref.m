% SUBSREF   serial port オブジェクト内のサブスクリプトの参照
%
% OBJ(I) は、サブスクリプトベクトル I で指定された OBJ の要素から
% フォーマットされた配列です。
%
% OBJ.PROPERTY は、serial port オブジェクト OBJ に対する PROPERTY の
% プロパティベクトルを出力します。
%
% serial port オブジェクトでサポートされるシンタックス:
%
%    正しくない記法:                Get 記法と等価な方法:
%    ===============                =====================
%    obj.Tag                        get(obj,'Tag')
%    obj(1).Tag                     get(obj(1),'Tag')
%    obj(1:4).Tag                   get(obj(1:4), 'Tag')
%    obj(1)                         
%
% 参考 : SERIAL/GET.


%    MP 7-13-99
%    Copyright 1999-2002 The MathWorks, Inc. 
