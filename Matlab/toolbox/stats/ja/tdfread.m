% TDFREAD   tabular形式データの読み込み
%
% TDFREAD は、ファイルを選択するためのダイアログボックスを表示し、
% ファイルからデータを読み込みます。ファイルは、ファイルの第一行に
% 列の名前をもち、タブで区切られた値の列から構成される必要があります。 
%
% TDFREAD(FILENAME) は、指定されたファイルを使わなければ同じです。
%
% TDFREAD(FILENAME,DELIMITER) は、タブの代わりに指定されたデリミタを
% 使います。DELIMITER で使える値は、以下のいずれかになります。
%        ' ', '\t', ',', ';', '|' または、これらに対応する文字列名
%        'space', 'tab', 'comma', 'semi', 'bar';
%        'tab'はデフォルトです。
%
% 参考 : TBLREAD.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:16:02 $
