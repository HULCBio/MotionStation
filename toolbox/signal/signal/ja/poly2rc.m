% POLY2RC  は、予測多項式を反射係数へ変換します。
% K = POLY2RC(A) は、予測多項式 A をベースに、反射係数Kを求めます。
%
% A(1) が1でない場合、POLY2RC は、A(1) で予測多項式を正規化します。
%
% [K,R0] = POLY2RC(A,Efinal) は、最終予測誤差 Efinal をベースにしたゼロ
% ラグの自己相関係数 R0 を出力します。 
% 
% 参考：   RC2POLY, POLY2AC, AC2POLY, RC2AC, AC2RC, TF2LATC.



%   Copyright 1988-2002 The MathWorks, Inc.
