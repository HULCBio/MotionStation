% TABLEREF   一般的なプロパティテーブルのインタフェース
% 
%   OUT=TABLEREF(CHGFIGPROPTABLE,'ACTION')
% 
%   有効な'ACTION'文字列:
%   GetPropList(filter)        - フィルタが変更されたときに呼び出されま
%                                す。フィルタに対するプロパティのリスト
%                                を与えます。
%   GetFilterList              - 起動時に呼び出されます。有効な全てのフ
%                                ィルタのリストを取得します。
%   GetFormatList              - 起動時に呼び出されます。"display prop-
%                                erty as"ポップアップに対する有効なレン
%                                ダリングオプションのリストを取得します。
%   GetPropCell(cell,property) - 実行中に呼び出されます。文法解釈されな
%                                いセル構造体と解釈されたプロパティ名を
%                                与えます。
%   GetPresetList              - "apply preset table"ポップアップメニュ
%                                ーに対する全てのプリセットテーブルのリ
%                                ストを取得します。
%   GetPresetTable(tablename)  - テーブルに対する新たな属性の配列を出力
%                                します。





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:27:41 $
%   Copyright 1997-2002 The MathWorks, Inc.
