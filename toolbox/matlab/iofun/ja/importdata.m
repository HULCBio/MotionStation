% IMPORTDATA   ディスクからワークスペース変数をロード
%
% IMPORTDATA(FILENAME) は、FILENAME からワークスペースにデータをロード
% します。
% A = IMPORTDATA(FILENAME) は、FILENAME からデータを A にロードします。
%
% IMPORTDATA(FILENAME, D) は、列区切り子として D を使って、FILENAME 
% からデータをロードします。タブには、'\t'を使います。
%
% IMPORTDATA は、使用する補助関数を決定するために、ファイル拡張子を調べ
% ます。拡張子が FILEFORMATS で記されている場合、IMPORTDATA は、出力
% 引数の最大数を取り扱う適切な補助関数をコールします。拡張子が 
% FILEFORMATS に記されていない場合は、IMPORTDATA はFINFO をコールし、
% 使用する補助関数を決定します。補助関数が拡張子に対して決定できない場
% 合は、IMPORTDATA は区切り子をもつテキストとしてファイルを扱います。
% 補助関数からの空の出力は結果から除去されます。
%
% 注意: インポートされるファイルがASCIIテキストファイルで、また、
% IMPORTDATA がファイルのインポートに問題がある場合、IMPORTDATA 内の
% TEXTSCAN のシンプルなアプリケーションよりも、より細かい引数の設定を
% 使って TEXTSCAN を試してください。
% 注意: やや古い Excel の書式の読み込みに失敗した場合、Excel ファイルを
% Excel 2000 または 95 の書式として開くことで更新するか、Excel 2000 
% または Excel 95 として保存してください。
%
% 例題：
%
%    s = importdata('ding.wav')
% s =
%
%    data: [11554x1 double]
%      fs: 22050
%
%   s = importdata('flowers.tif');
%   size(s)
% ans =
%
%    362   500     3
%
% 参考： LOAD, FILEFORMATS, TEXTSCAN


% Copyright 1984-2002 The MathWorks, Inc.
