% RPTCONVERT   SGMLソースを希望する出力形式に変換
% RPTCONVERTは、Report Generatorによって作成されたタイプのDocBook SGML
% ソースファイルを、書式化されたドキュメントに変換します。
%
% RPTCONVERTは、入力引数を指定しないで呼び出した場合、変換のGUIを起動し
% ます。
%
%   RPTNAME=RPTCONVERT(SOURCE)
%   RPTNAME=RPTCONVERT(SOURCE,FORMAT)
%   RPTNAME=RPTCONVERT(SOURCE,FORMAT,STYLESHEET)
%
% SOURCEは、DocBookファイル名です('.sgml'拡張子付き、または、なし)
% FORMATは、各出力形式のタイプに対するユニークな識別コードです。
% 
%      HTML, RTF95, RTF9, FOT
% 
% FORMATを省略すると、HTMLに変換します。
% STYLESHEETは、スタイルシートのユニークな識別子です。スタイルシートのID
% のリストは、RPTCONVERT #STYLESHEETLISTとタイプすることにより出力されま
% す。IDは1列目にあり、説明は2列目にあります。STYLESHEETを省略すると、選
% 択したFORMATに対してデフォルトのスタイルシートを用います。
%
%   [RPTNAME,STATMSG]=RPTCONVERT(SOURCE,....)
%
% 2つの出力引数を指定して呼び出したとき、変換エンジンからのステータス
% メッセージが2番目の出力引数に出力されます。
%   
% 参考   SETEDIT, REPORT, RPTLIST, COMPWIZ


%   Copyright 1997-2002 The MathWorks, Inc.
