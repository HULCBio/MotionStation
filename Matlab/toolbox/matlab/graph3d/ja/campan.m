% CAMPAN   カメラをパン(回転)します
% 
% CAMPAN(DTHETA,DPTH) は、DTHETA, DPHI(共に単位は度)で設定され
% た量だけ、カメラ位置の周りでカレント軸のカメラターゲットを回転します。
% DTHETA は水平方向、DPHZ は垂直方向の回転です。
% 
% CAMPAN(DTHETA,DPHI,coordsys,direction) は、回転の中心を決定します。
% co-ordsys は、'data'(デフォルト)または 'camera' です。coordsys が 
% 'data' の場合は、カメラターゲットはカメラの位置と方向で指定された
% ラインの周りに回転します。方向は、'x','y','z'(デフォルト)または 
% [X Y Z] のいずれかです。coordysys が 'camera' の場合は、回転はカメラ
% の位置の周りになります。 
%
% CAMPAN(AX, ...) は、カレントのaxesの代わりに AX を使います。
%
% 参考：CAMDOLLY, CAMORBIT, CAMZOOM, CAMROLL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:36 $

