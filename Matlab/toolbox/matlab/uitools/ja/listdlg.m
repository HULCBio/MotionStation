% LISTDLG   リスト選択ダイアログボックス
% 
% [SELECTION,OK] = LISTDLG('ListString',S) は、リストから文字列または
% 複数の文字列を選択できるダイアログボックスを作成します。SELECTION は、
% 選択した文字列のインデックスのベクトルです(選択肢が1のモードでは、
% 長さ1です)。OKが0のときは [] です。
% ユーザがOKボタンを押せばOKは1で、Cancelボタンを押すかfigureを消去する
% と、OKは0です。
%
% 複数のアイテムが選択される場合は、1つのアイテム上でダブルクリックを
% するか、または、<CR>を押すと、OKボタンを押した状態と同じ機能を示します。
% <CR>を押すことは、OKボタンをクリックすることと同じです。<ESC>を押すこ
% とは、Cancelボタンをクリックすることと同じです。
%
% 入力は、パラメータと値の組合わせです。
%
% パラメータ		詳細
% 'ListString'	   リストボックスに対する文字列のセル配列
% 'SelectionMode'  文字列。'single' または 'multiple'。デフォルトは
%                  'multiple' です。
% 'ListSize'       リストボックスの[width height] (ピクセル単位)。
%                  デフォルトは、[160 300]です。
% 'InitialValue'   リストボックスのどのアイテムが最初に選択されているかを
%                  示すインデックスのベクトル。デフォルトは、最初のアイ
%                  テムです。
% 'Name'           figureのタイトルに対する文字列。デフォルトは、''です。
% 'PromptString'   リストボックスの上にテキストとして表示される文字列
%                  行列、または、文字列からなるセル配列。デフォルトは、
%                  {}  です。
% 'OKString'       OKボタンに対する文字列。デフォルトは、'OK'です。
% 'CancelString'   Cancelボタンに対する文字列。デフォルトは、'Cancel'です。
%
% 複数を選択する場合には、'Select all' ボタンが提供されています。
%
% 例題:
%     d = dir;
%     str = {d.name};
%     [s,v] = listdlg('PromptString','Select a file:',...
%                     'SelectionMode','single',...
%                     'ListString',str)


%   T. Krauss, 12/7/95, P.N. Secakusuma, 6/10/97
%   Copyright 1984-2002 The MathWorks, Inc.
