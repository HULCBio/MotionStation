% UIRESTORE   figureの中で、対話型で機能する部分を再ストア
%
% UIRESTORE(UISTATE) は、UISUSPEND をコールすることにより、一時停止される
% 前に、所有しているfigureウィンドウの状態を再ストアします。
% 入力 UISTATE は、ウィンドウのプロパティやfigure内のすべてのオブジェクト
% に対して、ボタンを押したときの機能に関する情報を含んだ UISUSPEND により
% 出力される構造体です。
%
% UIRESTORE(UISTATE, 'children') は、figureの子のみを更新します。
%
% UIRESTORE(UISTATE, 'nochildren') は、figureのみを更新します。
%
% UIRESTORE(UISTATE, 'uicontrols') は、figureの uicontrol 子のみ更新します。 
%
% UIRESTORE(UISTATE, 'nouicontrols') は、figureのuicontrol の子でないもの
% すべてと、figureを更新します。
%
% 参考： UISUSPEND.


%   Chris Griffin, 6-19-97
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:09:01 $

