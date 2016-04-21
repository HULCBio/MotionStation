% CONTROLSFRAME   uicontrolフレームのハンドルを出力
% S=CONTROLSFRAME(C,'FrameTitle')は、属性ページで用いるためのボーダフレ
% ームを作成し、以下のフィールドをもつ構造体Sを出力します。
%
%   S.FrameName    = FrameTitleを表示するテキストのUICONTROLのハンドル
%   S.Frame        = フレームのaxesのハンドルを含む2行1列のベクトル
%   S.FrameContent = 初期状態は空で、ユーザによる変更が可能なS構造体の部
%                    分です。
% c.x.LayoutManagerと同じ規則に従い、フレームの内容をレイアウトするため
% に、CONTROLSRESIZEによって用いられます。
%
% 参考: CONTROLSMAKE, CONTROLSRESIZE, CONTROLSUPDATE





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:42 $
%   Copyright 1997-2002 The MathWorks, Inc.
