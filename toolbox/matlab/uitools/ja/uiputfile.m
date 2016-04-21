% UIPUTFILE   ファイルを標準にセーブするためのダイアログボックス
%
% [FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE) は、
% ユーザが入力できるダイアログボックスを表示し、ファイル名とパスを表わ
% す文字列と選択されたフィルタのインデックスを戻します。有効なファイル名
% が指定されている場合は、正常に戻ります。既存のファイル名が指定、あるいは
% 選択された場合は、ワーニングメッセージが表示されます。ユーザは、Yes を
% 選択してファイル名を利用するか、あるいは、Noを選択して別のファイル名を
% 選択するためにダイアログに戻ることができます。
%
% パラメータ FILTERSPEC は、ダイアログボックスの中のファイルの初期表示を
% 決定するものです。たとえば、'*.m' は、すべての MATLAB M-ファイルを表示
% します。FILTERSPEC がセル配列の場合、最初の列は、拡張子の一覧を、2列
% 目は、記述の一覧として使われます。
%
% FILTERSPEC が文字列、またはセル配列の場合、"All files (*.*)" がリスト
% に付加されます。
%
% FILTERSPEC が空の場合、ファイルタイプのデフォルトリストが使われます。
%   
% FILTERSPEC がファイル名の場合、デフォルトのファイル名になり、ファイル
% の拡張子が、デフォルトのフィルタとして、使われます。
%
% パラメータ TITLE は、ダイアログボックスのタイトルを含む文字列です。
%
% 出力変数 FILENAME は、ダイアログボックスの中で選択されたファイル名を
% 含む文字列です。ユーザが、Cancel ボタンを押した場合、0 に設定されます。
%
% 出力変数 PATH は、ダイアログボックスの中に選択されたパス名を含む文字列
% です。ユーザが、Cancel ボタンを押した場合、0 に設定されます。
%
% 出力変数 FILTERINDEX は、ダイアログボックスで選択されたファイルの
% インデックスを返します。インデックスは1で始まります。ユーザが Cancel 
% ボタンを押した場合、0 に設定されます。
%
% [FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE, FILE)
% 表示されている拡張子の代わりに指定された FILE を使います。
%
% [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])は、ダイア
% ログボックスをスクリーン位置[X,Y]にピクセル単位で置きます。このオプ
% ションは、UNIXプラットフォームでのみサポートされます。
%   
% [FILENAME, PATHNAME] = UIGETFILE(..., X, Y)は、ダイアログボックスを
% スクリーン位置[X,Y]にピクセル単位で置きます。このオプションは、UNIX
% プラットフォームでのみサポートされます。このシンタックスは、廃止されて
% おり削除される予定です。つぎのシンタックスを代わりに利用してください。
%     [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%
% 例題：
%
%   [filename, pathname] = uiputfile('matlab.mat', 'Save Workspace as');
%
%   [filename, pathname] = uiputfile('*.mat', 'Save Workspace as');
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'M-files (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Save as');
%
%   [filename, pathname, filterindex] = uiputfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Save as', 'Untitled.mat');
%
% 区切り子のない複数の拡張子は、セミコロンで分離しなければいけないこと
% に注意してください。
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Save as');
%
% つぎのように1つの区切り子で複数の拡張子を表すこともできます。
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Save as');
%
% このコードは、ユーザがダイアログのキャンセルを押した場合にチェック
% します。
%
%   [filename, pathname] = uiputfile('*.m', 'Pick an M-file');
%   if isequal(filename,0) | isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
% 参考：UIGETFILE, UIGETDIR.


%   Copyright 1984-2002 The MathWorks, Inc. 
