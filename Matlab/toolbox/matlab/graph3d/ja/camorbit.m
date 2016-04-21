% CAMORBIT   カメラの軌道
% 
% CAMORBIT(DTHETA,DPHI) は、カレント軸のカメラの位置を、カメラターゲット
% の周りに、DTHETA と DPHI(共に単位は度)分だけ回転します。DTHETA は
% 水平方向の回転、DPHI は垂直方向の回転です。
% 
% CAMORBIT(DTHETA,DPHI,coordsys,direction) は、回転の中心を決定します。
% coordsys は、'data'(デフォルト)または 'camera' です。coordsys が 
% 'data' の場合は、カメラの位置はカメラターゲットと方向で指定された
% ラインの周りで回転します。方向は、'X','Y','Z(デフォルト)'または 
% [X Y Z] のいずれかです。coordsys が、'camera' の場合は、回転はカメラ
% ターゲットの点の周りになります。
% 
% CAMORBIT(AX, ...) は、カレントのaxesの代わりに AX を使います。
%
% 参考：CAMDOLLY, CAMPAN, CAMZOOM, CAMROLL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:35 $

