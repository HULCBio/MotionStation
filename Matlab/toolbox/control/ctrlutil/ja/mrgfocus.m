% MRGFOCUS   周波数の範囲を1つに集中した形に融合
%
% FOCUS = MRGFOCUS(FRANGES,SOFTFLAGS) は、範囲のリストを単一の範囲に
% 融合(marge)します。信号を伝える範囲のブールベクトル SOFTFLAGS は弱く、
% 残りのダイナミクス(これらは擬似の積分、微分、またはダイナミクスのない
% 応答に対応しています)から、十分に離れていれば、無視できるものです。


%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2003/06/26 16:08:36 $
