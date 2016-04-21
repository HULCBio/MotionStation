% EXPORT2WSDLG   ワークスペースに変数を出力
%
% EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT) は、
% 一連のチェックボックスと編集フィールドをもつダイアログを作成します。
% CHECKBOXLABELS は、チェックボックスに対するラベルのセル配列です。
% DEFAULTVARIABLENAMES は、編集フィールドに現れる変数名のベースとなる
% 文字列のセル配列です。ITEMSTOEXPORT は、変数内に格納された値のセル
% 配列です。1つの項目のみ出力する場合、EXPORT2WSDLG は、チェックボックス
% の代わりにテキストコントロール(text control)を作成します。
%
% EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE) 
% は、タイトルとして TITLE を使ったダイアログを作成します。
%
% EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE, 
%                 SELECTED) 
% は、チェックボックスがチェックされるかどうかのコントロールを可能にする
% ダイアログを作成します。SELECTED は、CHECKBOXLABELS と同じ長さの論理
% 配列です。真は、チェックボックスが最初にチェックすること、偽はチェック
% されないことを示します。
%
% EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE, 
%                   SELECTED, HELPFUNCTION) 
% は、ヘルプボタンをもつダイアログを作成します。HELPFUNCTION は、ヘルプを
% 表示するコールバックです。
%
% EXPORT2WSDLG(CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, TITLE, 
%                   SELECTED, HELPFUNCTION, FUNCTIONLIST) 
% は、関数のセル配列と付加的な引数を FUNCTIONLIST に渡して計算することが
% 可能なダイアログを作成し、出力するための値を返します。
% FUNCTIONLIST は、CHECKBOXLABELS と同じ長さです。
%
% デフォルトの変数名を修正するためにテキストフィールドを編集することが
% できます。複数の編集フィールド内に同じ名前が現れる場合、EXPORT2WSDLG は、
% 名前を用いた構造体を作成します。そして構造体に対するフィールド名として、
% DEFAULTVARIABLENAMES を使用します。
%
% CHECKBOXLABELS, DEFAULTVARIABLENAMES, ITEMSTOEXPORT, SELECTED の長さは、
% すべて等しくなければなりません。
%
% DEFAULTVARIABLENAMES の文字列は、ユニークでなければなりません。


%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/11/26 19:12:44 $
