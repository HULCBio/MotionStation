% UICONTEXTMENU   ユーザインタフェースコンテキストメニューの作成
% 
% UICONTEXTMENU('PropertyName1',value1,'PropertyName2',value2,...) は、
% コンテキストメニューを作成し、そのハンドル番号を出力します。オブジェクト
% にコンテキストメニューを追加するには、オブジェクトの UICONTEXTMENU 
% プロパティを関数 UICONTEXTMENU によって出力されるハンドルに設定してくだ
% さい。メニュー項目は、関数 UIMENU を使ってコンテキストメニューに追加さ
% れます。
%
% コンテキストメニュープロパティは、UICONTEXTMENU の 
% PropertyName と PropertyValueの引数の組を使って、オブジェクトの作成時
% に設定されるか、または SET コマンドを使って後で変更できます。
%
% GET(H) を実行すると、UICONTEXTMENUオブジェクトのプロパティとそれらの
% カレント値のリストを見ることができます。SET(H) を実行すると、
% UICONTEXTMENUオブジェクトのプロパティと設定できるプロパティ値のリスト
% を見ることができます。詳細は、リファレンスガイドを参照してください。
%
% 参考：SET, GET, UIMENU.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:17 $
%   Built-in function.
