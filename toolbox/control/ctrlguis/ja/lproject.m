% LPROJECT   多角形のライン(polyline)上の点を推定
%
% [XP,YP] = LPROJECT(X,Y,XLINE,YLINE) は、(XLINE(i),YLINE(i)) の点に
% よって指定された多角形のライン(polyline)上の点 (X,Y) を推定します。
%
% [XP,YP] = LPROJECT(X,Y,XLINE,YLINE,AX) は、正規化された座標軸の単位
% として、(XP,YP) が "外観上最の最近傍の" 点となるよう推定します。
% AX は、対象のラインを含む座標軸のハンドルでなければなりません。


%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/06/26 16:06:58 $
