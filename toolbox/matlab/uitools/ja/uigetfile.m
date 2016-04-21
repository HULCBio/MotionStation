% UIGETFILE  標準的なオープンファイルのダイアログボックス 
%
%  [FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE) は、
% ユーザが入力するダイアログボックスを表示し、ファイル名とパスを表す
% 文字列を戻します。ファイルが存在する場合のみ、成功を表す結果が出力さ
% れます。ユーザが存在しないファイルを選択すると、エラーメッセージが
% 表示され、コントロールはダイアログボックスに返されます。その場合、
% ユーザは他のファイル名を入力するか、または、Cancel ボタンを押すことが
% できます。
%
% パラメータ FILTERSPEC は、ダイアログボックスの中のファイルの初期表示を
% 決定します。たとえば、'*.m' は、すべての MATLAB M-ファイルを表示します。
% FILTERSPEC がセル配列の場合、最初の列は拡張子の一覧を表示し、2番目
% の列は内容の一覧を表示します。
%
% FILTERSPEC が文字列、またはセル配列の場合は、"All files (*.*)" が
% リストに加えられます。
%
% FILTERSPEC が空の場合は、ファイルタイプのデフォルトリストが使われます。
%
% パラメータ TITLE は、ダイアログボックスのタイトルを含む文字列です。
%
% 出力変数 FILENAME は、ダイアログボックスの中に選択されたファイルの名
% 前を含む文字列です。ユーザがCancelボタンを押した場合、0に設定されます。
%
% 出力パラメータ PATHNAME は、ダイアログボックスの中に選択されるファイ
% ルのパスを含む文字列です。ユーザがCancelボタンを押した場合、0に設定
% されます。
% 
% 出力変数FILTERINDEXは、ダイアログボックスで選択したフィルタのインデック
% スを出力します。インデックス付けは、1から始まります。Cancelを押すと、
% 0に設定されます。
%
% [FILENAME, PATHNAME, FILTERINDEX] = UIGETTFILE(FILTERSPEC, TITLE, FILE)
% は、表示されている拡張子の代わりに指定された FILE を使います。
% 
% [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y]) は、ダイア
% ログボックスをスクリーン位置[X,Y]にピクセル単位で置きます。このオプション
% は、UNIXプラットフォームでのみサポートされます。
%   
% [FILENAME, PATHNAME] = UIGETFILE(..., 'MultiSelect', SELECTMODE)
% は、複数ファイルの選択がUIGETFILEダイアログに対して可能かどうかを指定
% します。SELECTMODEの有効な値は、'on' および'off'です。'MultiSelect' 
% の値が'on'に設定されている場合は、ダイアログボックスは複数ファイルの選
% 択をサポートします。'MultiSelect' は、デフォルトでは'off' に設定され
% ます。
%
% 出力変数FILENAMEは、複数ファイル名が選択されている場合は文字列からな
% るセル配列です。そうでない場合は、選択されたファイル名を表わす文字列です。
%   
% [FILENAME, PATHNAME] = UIGETFILE(..., X, Y) は、ダイアログボックスを
% スクリーン位置[X,Y]にピクセル単位で置きます。このオプションは、UNIX
% プラットフォームでのみサポートされます。このシンタックスは廃止されて
% おり、削除される予定です。以下のシンタックスを代わりに使用してください。
%     [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%
% 例題：
%
%   [filename, pathname] = uigetfile('*.m', 'Pick an M-file');
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'M-files (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file');
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file', 'Untitled.mat');
%
% 区切り子のない複数の拡張子は、セミコロンで分離しなければいけないこと
% に注意してください。
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Pick a file');
%
% つぎのように1つの区切り子で複数の拡張子を表すこともできます。
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Pick a file');
%
% このコードは、ユーザがダイアログのキャンセルを押した場合にチェック
% します。
%
%   [filename, pathname] = uigetfile('*.m', 'Pick an M-file');
%   if isequal(filename,0)|isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
% 参考：UIPUTFILE, UIGETDIR.


%   Copyright 1984-2002 The MathWorks, Inc. 
