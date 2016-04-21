%NOTEBOOK   Microsoft Word に M-book を開きます( Windows のみ)
% NOTEBOOK 自身では、Microsoft Word を起動し、"Document 1" と名付けた新しい
% M-book を作成します。
%
% NOTEBOOK(FILENAME) は、Microsoft Word を起動し、M-book FILENAME をオープン
% します。FILENAME が存在しない場合、FILENAME と名付けた新しい M-book を作成
% します。
%
% NOTEBOOK('-SETUP') は、NOTEBOOK 用の会話型の設定関数です。
% ユーザは、Microsoft Word のバージョンといくつかのファイルの位置をプロンプト
% に従って入力します。
%
% NOTEBOOK('-SETUP',WORDVER,WORDLOC,TEMPLATELOC) は、固有の情報を使って 
% Notebookを設定します。
% WORDVER は Microsoft Word ('97'または'2000'または'2002')のバージョン、
% WORDLOCは winword.exeを含むディレクトリ、TEMPLATELOC は Microsoft Word 
% のテンプレートディレクトリです。
%
% 例題
% notebook
% notebook c:\documents\mymbook.doc
% notebook -setup
%
% Microsoft Word 97(winword.exe) が、C:\Program Files\Microsoft Office 97
% \Office ディレクトリにインストールされ、C:\Program Files\Microsoft 
% Office 97\Templates directory ディレクトリに Microsoft Word テンプレートが
% インストールされている場合は、つぎのようになります。
%
% wordver = '97';
% wordloc = 'C:\Program Files\Microsoft Office 97\Office';
% templateloc = 'C:\Program Files\Microsoft Office 97\Templates';
% notebook('-setup', wordver, wordloc, templateloc)

% Copyright 1984-2003 The MathWorks, Inc.
