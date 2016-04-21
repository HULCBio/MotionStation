% TABLEREF は、基本的なプロパティテーブル 
%     OUT=TABLEREF(CSL_BLK_PROPTABLE,'ACTION') 
% へのインタフェースです。
% 
% 'ACTION' は、つぎの文字列を使用することができます。
% GetPropList(filter)        - フィルタを変更するときにコールされます。
%                              フィルタ用のプロパティリストを与えます。
% GetFilterList              - スタートアップ時にコールされます。すべて
%                              の使用可能なフィルタのリストを取得します。
% GetFormatList              - スタートアップ時にコールされます。"disp-
%                              lay property as"ポップ用に使用可能なレン
%                              ダリングオプションのリストを取得します。
% GetPropCell(cell,property) - 実行中にコールされます。文法的に解釈可能
%                              なプロパティ名と同様に文法的に解釈不能な
%                              セル構造体を与えます。
% GetPresetList              - "apply preset table"ポップアップメニュ用
%                              に前もって用意されているすべてのリストを
%                              取得します。
% GetPresetTable(tablename)  - テーブル用に新しい属性配列を出力します。



% $Revision: 1.9 $ $Date: 2002/06/17 12:23:29 $ 
% Copyright 1994-2002 The MathWorks, Inc. 
