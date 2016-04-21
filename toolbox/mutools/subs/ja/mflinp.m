%function [basic,sol,cost,lambda,tnpiv,flopcnt] = mflinp(a,b,c,startbasic)
%
%  *****  UNTESTED  *****
%
% MAGFITで実行される線形計画法に対するシンプレックスルーチン。MFLINPは、
% LINPの修正版で、MAGFIT内で構造体を作成し、定数を設定し、MAGFITの特殊な
% 構造に関連する性能の低下を防ぎます。
%
% 参考: FITMAG, LINP, MAGFIT, MFLP, MFFIXBAS.

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:17 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
