% CDFREAD   CDFファイルからのデータの読み込み
% 
% DATA = CDFREAD(FILE) は、FILEの各レコードからすべての変数を読み
% 込みます。DATA はセル配列で、各行がレコードで各列が変数です。CDF
% ファイルのデータの各部分が読み込まれ、出力されます。
% 
% DATA = CDFREAD(FILE, 'RECORDS', RECNUMS, ...) は、CDFファイルから
% 特定のレコードを読み込みます。RECNUMS は、単数または複数の、読み込
% まれるゼロベースのレコード番号からなるベクトルです。DATA は、行数が 
% length(RECNUM) のセル配列です。列の数は変数の数を同じです。
% 
% DATA = CDFREAD(FILE, 'VARIABLES', VARNAMES, ...) は、CDFファイル
% からセル配列VARNAMES内の変数を読み込みます。DATA は、列数が 
% length(VARNAMES) のセル配列です。要求される列に対して1行が存在し
% ます。
% 
% DATA = CDFREAD(FILE, 'SLICES', DIMENSIONVALUES, ...) は、CDFファ
% イル内の1変数から指定した値を読み込みます。行列 DIMENSIONVALUES 
% は、"start", "interval", "count" の値からなるm行3列の配列です。
% "start" の値はゼロベースです。
%
% DIMENSIONVALUES 内の行数は、変数の次元数以下でなければなりません。
% 未指定の行は、値 [0 1 N] を加えることによってそれらの次元からすべて
% の値を読み込みます。
% 
% 'Slices' パラメータの利用時には、一度に1つの変数しか読み込むことができ
% ないので、'Variables' パラメータを用いる必要があります。
% 
% [DATA, INF0] = CDFREAD(FILE, ...) は、INFO構造体内のCDFファイルに関す
% る詳細も出力します。
%
% 注意:
%
% CDFREAD は、CDF ファイルにアクセスする場合、テンポラリファイルを
% 作成します。カレントの作業ディレクトリは、書き込み可能である必要があります。
%
% 例題:
%
%     data = cdfread('example.cdf');
%
%       ファイルからすべてのデータを読み込みます。
%
%     data = cdfread('example.cdf', ...
%                    'Variable', {'Time'});
%
%       変数"Time"からデータを読み込みます。
%
%     data = cdfread('example.cdf', ...
%                    'Variable', {'multidimensional'}, ...
%                    'Slices', [0 1 1; 1 1 1; 0 2 2]);
%
%       変数"Multidimensional"内の最初の次元の1番目の値、2番目の次元の
%		2番目の値、3番目の次元の1番目と3番目の値を読み込み、
%		残りの次元のすべての値を読み込みます。これは、すべての
%		変数を "data" に読み込んでからMATLABコマンドを利用する
%               ことと同じです。
%
%         data{1}(1, 2, [1 3], :)
%
% 参考 ： CDFINFO, CDFWRITE.


%   Copyright 1984-2002 The MathWorks, Inc.
