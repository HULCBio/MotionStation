% TBLREAD   tabular形式のデータの読み込み
%
% [DATA, VARNAMES, CASENAMES] = TBLREAD は、対話形式で選択されたファイル
% からデータを読み込みます。ファイルの内容は、最初の行の中の変数(列)名で、
% 最初の列が名前(行)で、(2,2)がスペースキャラクタで区切られる数値データ
% の開始点になります。
%
% [DATA, VARNAMES, CASENAMES] = TBLREAD(FILENAME) は、指定されたファイル
% 名を用いて同様にデータを読み込みます。FILENAME は、希望するファイルを
% 示すパス名も完全に含んでいなければなりません。
%
% [DATA, VARNAMES, CASENAMES] = TBLREAD(FILENAME,DELIMITER) は、デリミタ
% のキャラクタとして DELIMITER を用いてファイルから読み込みを行います。
% DELIMITER には、つぎの値のいずれかを設定することができます。
%   ' ', '\t', ',', ';', '|' または、それに対応する文字列名、
%   'space', 'tab', 'comma', 'semi', 'bar'; 
%   'space' がデフォルトです。
%
% VARNAMES は、最初の行の中の変数名(列の名前)を含んだ文字行列です。
%
% CASENAMES は、最初の列の中の個々のケース名(行の名前)を含む文字行列です。
%
% DATA は、各変数とケース名がペアになったものに対する値をもつ数値行列です。
%
% 数値/テキストが混在したデータを読み込むには、TDFREAD を使用してください。
%
% 参考 : TDFREAD.


%   Copyright 1993-2003 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:15:58 $
