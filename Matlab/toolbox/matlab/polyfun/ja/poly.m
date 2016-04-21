% POLY   根を多項式に変換
% 
% A がN行N列行列のとき、POLY(A) は特性多項式 DET(lambda*EYE(SIZE(A)) - A)
% の係数を要素にもつN+1個の要素からなる行ベクトルです。
%
% V がベクトルのとき、POLY(V) は、V の要素を多項式の根とする多項式の係数
% となるベクトルです。ベクトルに対して、ROOTS と POLY とは、順序付け、
% スケーリング、丸め誤差について、お互いが逆関数です。
%
% ROOTS(POLY(1:20)) は、有名なWilkinsonの例題を出力します。
%
%   入力 A,V のサポートクラス
%      float: double, single
%
% 参考：ROOTS, CONV, RESIDUE, POLYVAL.


%   Original by J.N. Little 4-21-85.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:40 $
