%SETWTBO   オブジェクトフィールドの内容を設定
%   O = SETWTBO(O,'FieldName1','FieldValue1','FieldName2','FieldValue2'
%    ...) は、Wavelet Toolbox の任意のオブジェクト O で指定されるフィー
%   ルドの内容を設定します。
%
%   最初に、O が検索されます。失敗した場合、サブオブジェクトと下位の構造%   体フィールドが調べられます。
%
%   注意: SETWTBO 関数は使用できません!

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.

O = wsfields(Inf,O,varargin{:});


%   Copyright 1995-2002 The MathWorks, Inc.
