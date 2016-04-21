% DIALOG  ダイアログのfigureの作成
% 
% H = DIALOG(... )は、ダイアログボックスのハンドル番号を出力します。
% この関数は、FIGURE コマンドに対するラッパー関数です。さらに、ダイアログ
% ボックスについて推奨されるfigureのプロパティを設定します。プロパティ
% と対応する値を以下に示します。
%
%  'BackingStore'      - 'off'
%  'ButtonDownFcn'     - 'if isempty(allchild(gcbf)), close(gcbf), end'
%  'Colormap'          - []
%  'Color'             - DefaultUicontrolBackgroundColor
%  'HandleVisibility'  - 'callback'
%  'IntegerHandle'     - 'off'
%  'InvertHardcopy'    - 'off'
%  'MenuBar'           -     MAC = 'figure' others = 'none'
%  'NumberTitle'       - 'off'
%  'PaperPositionMode' - 'auto'
%  'Resize'            - 'off'
%  'Visible'           - 'on'
%  'WindowStyle'       - 'modal'
% 
% このコマンドに対して、figureコマンドの任意のパラメータが使用可能です。
% 
% 参考：FIGURE, UIWAIT, UIRESUME


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:52 $
