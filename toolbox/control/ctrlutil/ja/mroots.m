% MROOTS   重根をもつ多項式の根を推定
%
% R = MROOTS(P) は、多項式 P の根 R を計算します。そして、真の値と重根の
% 重複度を計算します。
%
% R = MROOTS(P,TOL) は、さらに、重根により根のクラスタ近似を行う場合、P 
% の係数に許容範囲の相対誤差 TOL も設定します(デフォルト = SQRT(EPS))。
%
% 参考 : ROOTS.


%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $   $Date: 2003/06/26 16:08:37 $
