% CAMDOLLY   カメラの移動
% 
% CAMDOLLY(DX,DY,DZ) は、DX, DY, DZで設定した量だけ、カレントのaxesの
% カメラの位置とカメラターゲットを移動します。
% 
% CAMDOLLY(DX,DY,DZ,targetmode) は、カメラターゲットが移動するか否かを
% 決定します。targetmode が 'movetarget'(デフォルト)の場合は、カメラの位置
% もカメラターゲットも移動します。targetmode が 'fixtarget' の場合は、カメラ
% の位置だけが移動します。
% 
% CAMDOLLY(DX,DY,DZ,targetmode,coordsys)は、DX, DY, DZの意味を決定
% します。coordsys が、'camera'(デフォルト)の場合、DX と DY は、カメラの座
% 標システム内でカメラを上下、左右に移動します。DZ は、カメラ位置とカメラ
% ターゲットを通るライン上に沿ってカメラを移動します。単位は、表示される視
% 点で正規化されます。たとえば、DX が1の場合はカメラが右に移動し、axesの
% 位置で形成されるボックスの左端に視点を置きます。DZ が0.5の場合は、カ
% メラはカメラ位置とターゲットの半分の位置に移動します。coordsys が 'pixels'
% の場合は、DX と DY はピクセルのオフセットとして解釈され、DZ は無視され
% ます。coordsys が 'data' の場合は、DX, DY, DZはカメラの座標系ではなく、
% データ空間内の座標系になります。
% 
% CAMDOLLY(AX, ...) は、カレント軸の代わりに軸 AX を使います。
%
% 参考：CAMORBIT, CAMPAN, CAMZOOM, CAMROLL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:54:31 $


