% SET は、xPC オブジェクト用の設定メソッドを実行します。
% 
% SET(XPCOBJ, PROPERTYNAME, PROPERTYVALUE....) は、XPCOBJ で表されるターゲ
% ットのプロパティを設定します。すべてのプロパティはユーザが記述できるもの
% ではありません。すなわち、SET(XPCOBJ) を実行すると、記述できるプロパティ
% のリスト、および、プロパティ値(可能性のある有限数)を取得 できます。プロ
% パティは、リストで示される名前と値の組で入力してください。別のシンタック
% スset(XPCOBJ, PROPERTYNAME, PROPERTYVALUE) も使えます。ここで、PROPERT-
% YNAME と PROPERTYVALUE は、同じサイズの1次元のセル配列(これは、共に、行
% ベクトル、または、列ベクトルであることを意味しています)です。そして、P-
% ROPERTYNAME の中のプロパティに対する値が 、PROPERTYVALUE にストアされま
% す。SET は、一般には、値を出力しません 。しかし、出力引数を明示的に設定
% して使用すると、たとえば、
% 
%    A = SET(XPCOBJ, PROPERTYNAME, PROPERTYVALUE) 
% 
% は、指定された設定が行われた後、XPCOBJ の値を出力します。このコマンドは、
% A =SET(XPCOBJ) に何も影響を与えません。
% 
% XPCOBJ は、スカラでなければなりません。
% 
% 参考： GET, SET/GET 組み込み関数

%   Copyright 1994-2002 The MathWorks, Inc.
