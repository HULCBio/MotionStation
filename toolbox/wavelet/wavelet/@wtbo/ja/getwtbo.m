%GETWTBO   オブジェクトフィールドの内容を取得
%   [FieldValue1,FieldValue2, ...] = ...
%       GETWTBO(O,'FieldName1','FieldName2', ...) は、Wavelet Toolbox の%   任意のオブジェクト O で指定されるフィールドの内容を出力します。
%
%   最初に、O が検索されます。失敗した場合、サブオブジェクトと下位の構造%   フィールドが調べられます。
%
%   例題:
%     t = ntree(2,3);   % t は、NTREE オブジェクトです。
%     [o,wtboInfo,tn,depth] = getwtbo(t,'order','wtboInfo','tn','depth');
%
%     t = wpdec(rand(1,120),3,'db3');  % t は、WPTREE オブジェクトです。%     [o,tn,Lo_D,EntName] = getwtbo(t,'order','tn','Lo_D','EntName');

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.


%   Copyright 1995-2002 The MathWorks, Inc.
