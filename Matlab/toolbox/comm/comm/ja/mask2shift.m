% MASK2SHIFT   シフトレジスタの構成に対してマスクベクトルをシフトに変換
%
% SHIFT = MASK2SHIFT(PRPOLY, MASK) は、その接続が原始多項式 PRPOLY で
% 与えられる線形フィードバックシフトレジスタに指定されたマスクに対する
% 等価なシフトを出力します。
%
% 原始多項式 PRPOLY は、降べきの係数のバイナリベクトルか、等価な10進数
% のスカラのどちらかでなければなりません。
% MASK パラメータは、多項式の次数に等しい長さのバイナリベクトルでなけ
% ればなりません。
%  
% 例題:
%     多項式 x^3 + x + 1 とマスク x^2 に対して実行
%     s = mask2shift([1 0 1 1],[1 0 0])
%     結果
%
%     s = 
%
%          2
%
% 参考: SHIFT2MASK, GF/LOG, ISPRIMITIVE, PRIMPOLY, DE2BI.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/06/23 04:35:00 $
