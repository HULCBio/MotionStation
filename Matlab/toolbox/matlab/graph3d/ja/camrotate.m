% CAMROTATE   カメラの回転のユーティリティ関数
%
% [pos、newUp] = CAMROTATE(a,b,dar,up,dt,dp,coordsys,direction)
%
% 点 b または b を含むラインを中心として、点 a (と上向きのベクトル up)
% を回転するためのユーティリティ関数です。
% coordsys が 'camera 'の場合は、点 b を中心に回転します。
% coordsys が 'data' の場合は、点 b と direction で指定されるラインを
% 中心に回転します。
%   
% 参考：CAMORBIT, CAMPAN , CAMLIGHT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:54:40 $

