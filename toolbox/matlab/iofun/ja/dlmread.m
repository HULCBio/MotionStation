% DLMREAD   ASCIIデリミタ付きファイルを行列として読み込みます
% RESULT = DLMREAD(FILENAME) は、ASCIIデリミタ付きファイル FILENAME から
% 数値データを読み込みます。  デリミタは、ファイルの書式から推測されます。
% 
% RESULT = DLMREAD(FILENAME,DELIMITER) は、デリミタ DELIMITER を
% 使って、ASCIIデリミタ付きファイル FILENAME からデータを読み込みます。
% 結果は、RESULT に出力されます。タブを指定するためには、'\t'を使って
% ください。
%
% デリミタが、ファイルの書式から推測される場合、連続する空白は1つの
% デリミタとして取り扱われます。これに対して、デリミタが DELIMITER 
% 入力により指定される場合、繰り返されるデリミタ文字は別々のデリミタ
% として取り扱われます。
%
% RESULT = DLMREAD(FILENAME,DELIMITER,R,C) は、DELIMITERデリミタファイル
% FILENAME からデータを読み込みます。R と C は、ファイル内のデータの
% 左上隅の位置である行 R と列 C を指定します。R と C は、ゼロを基準と
% しているので、R = 0 と C = 0 は、ファイル内の最初の値を指定します。
%
% RESULT = DLMREAD(FILENAME,DELIMITER,RANGE) は、(R1,C1) が左上隅で、
% (R2,C2) が右下隅のとき、RANGE = [R1 C1 R2 C2] で指定される範囲のみを
% 読み込みます。RANGE は、RANGE = 'A1..B7 'のようなスプレッドシート
% の表記法を使っても指定できます。
%
% DLMREAD は、空のデリミタフィールドを0に設定します。スペースのないデリ
% ミタでラインが終了しているデータファイルは、すべての要素をゼロで設定
% した列を最終列に追加した結果を作成します。
%
% 参考 DLMWRITE, TEXTSCAN, TEXTREAD, LOAD, FILEFORMATS

%   Copyright 1984-2002 The MathWorks, Inc.
