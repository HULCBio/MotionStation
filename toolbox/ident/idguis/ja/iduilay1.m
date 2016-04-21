% IDUILAY1 は、整然と配置されるようにuicontrol の位置を計算する補助関数
% 
%   figwh         = フィギュアの幅と高さ
%   nobut         = ボタンの数
%   layers        = レイアの数
%   level         = スタートのレベル (ボトムの場合 0 )
%   betw_but_vert = ボタン間の垂直距離
%   width_fact    = ボタン幅に乗算するファクタ。長さ NOBUT/LAYERS のベク
%                   トルになる場合があります。
% POS: フレーム回りや、対応する nobut uicontrol の位置を含む行列
%
% フレームとコントロール間の垂直距離は、常に、mStdButtonHeight/2 で、一
% 方、ボタン間の垂直距離は、betw_but_vert です。

%   Copyright 1986-2001 The MathWorks, Inc.
