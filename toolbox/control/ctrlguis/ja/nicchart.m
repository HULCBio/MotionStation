% NICCHART   Nichols線図のグリッドを作成
%
% [PHASE,GAIN,LABELS] = NICCHART(PMIN,PMAX,GMIN) は、Nichols 線図を
% プロットするためのデータを作成します。PMIN と PMAX は、度単位で表した
% 位相の間隔で、GMIN はdB単位で表した最小ゲインです。NICCHART は、
% つぎのものを出力します。
%    * PHASE と GAIN: グリッドデータ
%    * LABELS: x と y の位置とラベル値からなる3行の行列
%
% [GRIDHANDLES,TEXTHANDLES] = NICCHART(AX) は、座標軸 AX 内に、Nichols線図
% をプロットします。NICCHART は、現在の座標軸の範囲を使用します。
%
% [GRIDHANDLES,TEXTHANDLES] = NICCHART(AX,OPTIONS) は、付加的なグリッド
% オプションを指定します。OPTION は、以下のフィールドをもつ構造体です。:
%      * PhaseUnits: 'deg' または 'rad' (デフォルト = deg)
%      * Zlevel    : 実数のスカラ (デフォルト = 0)
%
% 参考 : NICHOLS, NGRID.


%   Authors: K. Gondoly and P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:06 $
