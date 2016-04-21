% HILITE_SYSTEM   Simulink オブジェクトのハイライト
%
% HILITE_SYSTEM(SYS) は、オブジェクトを含むシステムウィンドウを開き、
% Simulink オブジェクト点滅させ、HiliteAncestors プロパティを使ってオブジェ
% クトを点滅させます。
%
% ユーザは、HILITE_SYSTEM の右辺に引数を付加して、点滅するオプションを設定でき
% ます。オプションは、以下のものが含まれます。
%
%  default     'default'の点滅手法を使ったハイライト　　　　none        ハイラ
% イトを消す　　　　　　　　　　　　find        'find'の点滅手法を使ったハイライト　　
% unique      'unique'の点滅手法を使ったハイライト　different   '
% different'の点滅手法を使ったハイライト　　　　　　　　　　user1       'user1'の点滅
% 手法を使ったハイライト　　　　　user2       'user2'の点滅手法を使ったハイライ
% ト　　　　　　user3       'user3'の点滅手法を使ったハイライト　　　　　user4
% 'user4'の点滅手法を使ったハイライト　　　　　user5       'user5'の点滅手法を使っ
%
% 点滅手法のカラーを変えるには、以下のコマンドを使用します。
%
%  set_param(0, 'HiliteAncestorsData', HILITEDATA)
%
% ここで、HILITEDATA は、以下のフィールドをもつMATLAB構造体です。
%
%  HiliteType       上記にリストされた点滅手法のひとつ ForegroundColor
% (以下にリストされる)カラーの文字列 BackgroundColor  (以下にリストされる)
%
% 設定可能なカラーは、'black', 'white', 'red', 'green', 'blue', 'yellow','
% magenta', 'cyan', 'gray', 'orange', 'lightBlue', 'darkGreen' です。
%
% 例題:
%
% % サブシステム 'f14/Controller/Stick Prefilter'を点滅させます。
% hilite_system('f14/Controller/Stick Prefilter')
%
% % 'error'点滅手法でサブシステム 'f14/Controller/Stick Prefilter'
% % を点滅させます。
% hilite_system('f14/Controller/Stick Prefilter', 'error')
%
% 参考 : OPEN_SYSTEM, FIND_SYSTEM, SET_PARAM


% Copyright 1990-2002 The MathWorks, Inc.
