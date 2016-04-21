% SHIFT2MASK   シフトレジスタの構成に対してシフトをマスクベクトルに変換
%
% MASK = SHIFT2MASK(PRPOLY, SHIFT) は、その接続が原始多項式 PRPOLY で
% 与えられる線形フィードバックシフトレジスタに指定されたシフト(または
% オフセット)に対する等価なマスクを出力します。
%  
% 原始多項式 PRPOLY は、降べきの係数のバイナリベクトルか、等価な10進数
% のスカラのどちらかでなければなりません。
% SHIFT パラメータは、整数のスカラでなければなりません。
%  
% 例題:
%   多項式 x^3 + x + 1 と2のシフトに対して実行
%   m = shift2mask([1 0 1 1], 2)
%   結果
%
%   m = 
%
%        1  0  0
%
% 参考: MASK2SHIFT, GF/DECONV, ISPRIMITIVE, PRIMPOLY, DE2BI.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/06/23 04:35:18 $
