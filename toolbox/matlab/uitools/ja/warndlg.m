% WARNDLG   ワーニングダイアログボックス
% 
% HANDLE = WARNDLG(WARNSTRING,DLGNAME) は、DLGNAME というウィンドウ
% に 、WARNSTRING を表示するワーニングダイアログボックスを作成します。
% ワーニングボックスを消去するためには、OKとラベル付けられたプッシュ
% ボタンを押さなければなりません。
%
% HANDLE = WARNDLG(WARNSTRING,DLGNAME,CREATEMODE) は、MSGBOX で提唱される
% ものと同じ CREATEMODE を使います。CREATEMODE のデフォルト値は、
% 'non-modal' です。
%
% WARNSTRING は、任意の有効な文字列の書式で構いませんが、セル配列が
% 好ましいです。
% 
%  参考： MSGBOX, HELPDLG, QUESTDLG, ERRORDLG, WARNING.


%  Author: L. Dean
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:09:14 $
