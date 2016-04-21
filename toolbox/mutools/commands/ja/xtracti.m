% function matout = xtracti(mat,ivindex,ascon)
%
% MATがVARYING行列で、IVINDEXがつぎのような正の整数配列の場合、
%
%       MAX(IVINDEX) <= LENGTH(GETIV(MAT))
%
% MATOUTはIVINDEX番目の独立変数値に関連する行列です。MATOUTは、デフォル
% トではVARYING行列です。オプションの3番目の引数ASCONが正の数に設定され
% ると、MATOUTは、抽出されたデータを含むCONSTANT行列です。
%
% MATがCONSTANTまたはSYSTEM行列で、INDVINDXが正の整数の場合、MATOUTはMAT
% と等しくなります。
%
% 参考: GETIV, MINFO, SCLIV, SEL, VAR2CON, XTRACT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
