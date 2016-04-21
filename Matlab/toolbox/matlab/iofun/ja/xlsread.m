% XLSREAD Excel ワークブックのスプレッドシートからのデータおよびテキストの取得
% [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE) は、FILE に指定された Excel 
% ファイルのワークシート SHEET から RANGE に指定されたデータを読み込みます。
% FILE の数値セルは、NUMERIC に出力され、FILE のテキストセルは、TXT に
% 出力されます。また、未処理のセルの内容は、RAW に出力されます。データの
% 範囲を対話的に選択することができます。 (下記の例題を参照)。XLSREAD の
% 完全な機能は、Excel を MATLAB から COM サーバとして起動する機能に依存する
% ことに注意してください。
%
% [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE,'basic') は、基本入力モードを
% 使用して、上記のように XLS ファイルを読み込みます。これは、Excel が COM 
% サーバとして利用できない場合、Windows 上と同様に UNIX プラットフォームでも
% 使用されるモードです。
% このモードでは、XLSREAD は、Excel を COM サーバとして使用しないため、
% インポート機能に制限があります。COM サーバとして Excel が利用できない場合、
% RANGE が無視され、結果として、シートのアクティブな範囲全体がインポートされ
% ます。また、基本モードで、シートは大文字と小文字を区別する文字列として
% 指定する必要があります。
%
% 入力パラメータ
% FILE: 読み込みのファイルを定義する文字列。デフォルトのディレクトリ
%       は、pwd です。
%       デフォルトの拡張子は、'xls' です。NOTE 1 を参照してください。
% SHEET:ワークブック FILE でワークシート名を定義する文字列
%       ワークブック FILE のワークシートインデックスを定義する double のスカラー

% RANGE: ワークシートでデータの範囲を定義する文字列。 NOTE 2 を参照して
%        ください。
% MODE: 基本的なインポートモードを強制する文字列。適切な値 = 'basic'.
%
% RETURN PARAMETERS:
% NUMERIC = double タイプの n x m 配列
% TXT = RANGE にテキストセルを含む r x s セル文字列配列
% RAW = 未処理の数値 および テキストデータを含む v x w セル配列
% NUMERIC および TXT は、RAW のサブセットです。
%
% 例題:
%   1. デフォルトの操作:  
%      NUMERIC = xlsread(FILE);
%      [NUMERIC,TXT]=xlsread(FILE);
%      [NUMERIC,TXT,RAW]=xlsread(FILE);
%
%   2. デフォルトの領域からのデータの取得
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet')
%
%   3. 最初のシート以外のシートの使用した領域からのデータの取得:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','sheet2')
%
%   4. シート名を指定して、データを取得
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','NBData')
%
%   5. 最初のシート以外のシートの指定した領域からのデータの取得
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','sheet2','a2:j5')
% 
%   7. 指定した名前のシートの指定領域からのデータの取得
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','NBData','a2:j5')
% 
%   8. インデックスにより指定したシート領域からのデータの取得
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet',2,'a2:j5')
% 
%   9. 対話による領域の選択:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet',-1);
%      フォーカスされる EXCEL ウィンドウ内で、アクティブな領域と
%      アクティブなシートを選択する必要があります。
%      アクティブな領域の選択を終了するとき、Matlab コマンドラインで
%      何か文字を入力してください。
%
% 注意 1: FILE が空の文字列または省略される場合、エラーが発生します。
% 注意 2: ワークブックの最初のワークシートが、デフォルトのシートです。
%         SHEET が -1 の場合、Excel が前に表示され、対話的な選択ができます
%         (オプション)。対話的なモードでは、ダイアログがユーザに ダイアログ
%         内の OK ボタンをクリックするように促し、MATLAB で続けられます。
% 注意 3: 標準的には、つぎのようになります。
%         'D2:F3' ワークシート内の長方形の領域 D2:F3 を選択します。
%         RANGE は、大文字と小文字の区別はせず、Excel A1 の記号
%         を使用します (Excel Help を参照)。
%
% 参考 XLSWRITE, CSVREAD, CSVWRITE, DLMREAD, DLMWRITE, TEXTREAD.

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc.
