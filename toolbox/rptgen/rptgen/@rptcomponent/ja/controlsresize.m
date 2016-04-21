% CONTROLSRESIZE コンポーネントの属性ページのuicontrolをリサイズ
% C=CONTROLSRESIZE(C)は、C.x.LayoutManagerで指定されたuicontrolをレイア
% ウトします。C.x.LayoutManagerは、セル配列、ハンドル、文字列、フレーム
% 構造体を含むセル配列です。
%
% 各セル配列は、それ自身がグリッドを形成します。グリッドは、利用可能な水
% 平方向の空間を調整して、利用可能な垂直方向の空間を考慮せずに下方に拡張
% して、ダイナミックに作成されます。
%
% 配列内の各要素は、以下のいずれかでなければなりません。
% 
%   * 単一のUIcontrolのハンドル(uicontrolのベクトルは利用できません)
%   * 数値 
%     - スペーサとして機能する数値
%     - 1行1列の[M]の数値は、M点のスペースを水平方向および垂直方向に挿入
%       します。
%     - 2行1列の[M N]の数値は、M点を水平方向に、N点を垂直方向に挿入しま
%       す。
%     - M = infの場合は、スペーサはエディットボックスと同じスペースをと
%       ります。
%     - m = -infの場合は、スペーサは利用可能なスペースをとります。
%   *文字列 
%     - 文字列の中には、数値の組合わせを示すものがあります。
%     - 'indent' は、[20 1]と同じです。
%     - 'spacer' は、[inf 1]と同じです。
%     - 'buffer' は、[-inf 1]と同じです。
%   *構造体 
%     - CONTROLSFRAMEは、CONTROLSRESIZEによって読み込まれる構造体を出力
%       します。'FrameContent'フィールドは、C.x.LayoutManagerと同じ規則
%       に従います。
%
% 最後のUIcontrolの最小のYの位置は、c.x.lowLimitに出力されます。c.x.lo-
% wLimitが利用可能な最小のYの位置(c.x.yzero)よりも小さい場合は、c.x.al-
% lInvisibleが適用され"error"スクリーンが属性ページの代わりに表示されま
% す。
%
% 参考: CONTROLSMAKE, CONTROLSUPDATE, CONTROLSFRAME





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:44 $
%   Copyright 1997-2002 The MathWorks, Inc.
