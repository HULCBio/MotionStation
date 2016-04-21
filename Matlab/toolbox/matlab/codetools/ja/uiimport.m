%UIIMPORT データインポート用の GUI(Import Wizard)を起動
%
% UIIMPORT は、カレントディレクトリに Import Wizard を起動します。ファイル、
% または、クリップボードからデータをロードするオプションが存在します。
%
% UIIMPORT(FILENAME) は、Import Wizard を起動し、FILENAME にオープンする
% ファイル名を指定します。Import Wizard は、ファイルの中のデータのプレビュー
% を表示します。
%
% UIIMPORT('-file') は、上述したように起動しますが、ファイル選択ダイアログ
% が最初に存在します。
% 
% UIIMPORT('-pastespecial') は、上述したように起動しますが、クリップボード
% の内容が最初に存在します。
%
% S = UIIMPORT(...) は、上述したように起動しますが、構造体 S のフィールド
% として、結果の変数を出力します。
%
% ASCII データに対して、Import Wizard は、列の区切りを識別することが必要に
% なります。
%
% 参考 LOAD, FILEFORMATS, CLIPBOARD, IMPORTDATA.

%   Copyright 1984-2004 The MathWorks, Inc.
