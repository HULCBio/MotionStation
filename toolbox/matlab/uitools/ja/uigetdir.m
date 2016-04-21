%  UIGETDIR   標準のオープンディレクトリダイアログボックス
%
% DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE) は、ディレクトリ構造を
% 表示し、ディレクトリを選択し、ディレクトリ名を文字列として出力する
% ダイアログボックスを表示します。ディレクトリが存在する場合は、正常に
% 出力します。
%
% STARTPATH パラメータは、ダイアログボックス内の初期のディレクトリと
% ファイルの表示を決定します。
%
% STARTPATH が空の場合は、ダイアログボックスは、カレントディレクトリに
% オープンされます。
%
% STARTPATH が有効なディレクトリパスを表わす文字列の場合は、ダイアログ
% ボックスは、指定したディレクトリにオープンされます。
%
% STARTPATH が有効なディレクトリパスでない場合は、ダイアログボックスは、
% ベースディレクトリにオープンされます。
%
% Windows:
% ベースディレクトリは、Windows Desktopディレクトリです。
%
% UNIX: 
% ベースディレクトリは、ＭＡＴＬＡＢを起動するディレクトリです。ダイア
% ログボックスは、デフォルトですべてのファイルタイプを表示します。表示
% されるファイルのタイプは、ダイアログボックスのSelected Directory
% フィールドのフィルタ文字列を変更することによって、変更することができ
% ます。ユーザがディレクトリではなくファイルを選択した場合は、ファイル
% を含むディレクトリが出力されます。
%
% パラメータ TITLE は、ダイアログボックスのタイトルを含む文字列です。
% TITLE が空の場合は、デフォルトのタイトルがダイアログボックスに割り
% 当てられます。
%
% Windows:
% TITLE 文字列は、ユーザへの指示を指定するダイアログボックス内のデフォ
% ルトのキャプションを置き換えます。
%
% UNIX:
% TITLE 文字列は、ダイアログボックスのデフォルトのタイトルを置き換え
% ます。
%
% 入力パラメータが指定されないときは、ダイアログボックスはデフォルトの
% ダイアログタイトルを使ってカレントディレクトリにオープンします。
%
% 出力パラメータ DIRECTORYNAME は、ダイアログボックスで選択されたディ
% レクトリを含む文字列です。ユーザがCancelボタンを押した場合は、0を
% 出力します。
%
% 例題:
%
%   directoryname = uigetdir;
%
%   Windows:
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB');
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');
%
%   UNIX:
%   directoryname = uigetdir('/home/matlab/work');
%   directoryname = uigetdir('/home/matlab/work', 'Pick a Directory');
%
% 参考 ： UIGETFILE, UIPUTFILE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:08:55 $
%   Built-in function.