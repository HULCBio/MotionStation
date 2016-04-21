% SET は、xPC オブジェクト用の設定メソッドを実行します。
% 
% SET(XPCSCOPEOBJ, PROPERTYNAME, PROPERTYVALUE....) は、XPCSCOPEOBJ で表さ
% れるスコープのプロパティを設定します。すべてのプロパティはユーザが記述で
% きるものではありません。すなわち、SET(XPCSCOPEOBJ) は、記述できるプロパ
% ティのリスト、および、プロパティ値(可能性のある有限数)を取得できます。プ
% ロパティは、リストで示される名前と値の組で入力してください。別のシンタッ
% クス set(XPCSCOPEOBJ, PROPERTYNAME, PROPERTYVALU E) も使えます。ここで、
% PROPERTYNAME と PROPERTYVALUE は、同じサイズの1次元のセル配列(これは、共
% に、行ベクトル、または、列ベクトルであることを意味しています)です。そし
% て、PROPERTYNAME の中のプロパティに対 する値が、PROPERTYVALUE にストアさ
% れます。SET は、一般には、値を出力しません。しかし出力引数を明示的に設定
% して使用すると、たとえば、
% 
%   A = SET(XPCSCOPEOBJ, PROPERTYNAME, PROPERTYVALUE) 
% 
% は、指定された設定が行われた後、XPCOBJ の値を出力します。この型は、A =
% SET(XPCSCOPEOBJ) に何も影響を与えません。
% 
% XPCSCOPEOBJ は、スカラでなければなりません。
% 
% 参考： GET, SET/GET 組み込み関数

%   Copyright 1994-2002 The MathWorks, Inc.
