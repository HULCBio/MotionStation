% SET   AVIFILE オブジェクトのプロパティの設定
%
% OBJ = SET(OBJ,'PropertyName',VALUE) は、AVIFILEオブジェクト OBJ の
% プロパティ'PropertyName'に値 VALUE を設定します。  
%
% OBJ = SET(OBJ,'PropertyName',VALUE,'PropertyName',VALUE,..) は、単一
% のステートメントで、AVIFILEオブジェクト OBJ の複数のプロパティ値を
% 設定します。
%
% 注意: この関数は、SUBSASGN 用の補助関数で、ユーザの使用を対象とした
%       ものではありません。AVIFILEオブジェクトの適切な値を設定するには
%       構造体記法を使ってください。例えばつぎのようにします。:
%
%       obj.Fps = value;
%


%   Copyright 1984-2002 The MathWorks, Inc.
