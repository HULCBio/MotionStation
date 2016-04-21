% XLSFINFO 　ファイルがMicrosoft Excelスプレッドシートを含んでいるかを決定
% 
%   [A, DESCR] = XLSFINFO('FILENAME')
%
% FILENAME が読み取り可能なExcel spreadsheetを含んでいる場合は、A は空
% にはなりません。
%
% DESCR は、内容の記述、またはエラーメッセージのいずれかを示します。
%
%
% 注意 1: この関数は、コンパイラと共に機能しません。
% 注意 2: Excel の ActiveX サーバが開始できない場合、機能的に、いくつか
%         のExcelファイルが読み込み可能でないよう制限されています。
%
% 参考：XLSREAD, CSVREAD, TEXTREAD.


%   Copyright 1984-2002 The MathWorks, Inc. 
