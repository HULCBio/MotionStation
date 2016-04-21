% CROSS   ベクトルの外積
% 
% C = CROSS(A,B) は、ベクトル A と B の外積を出力します。すなわち、
% C = A x B です。A と B は、3要素のベクトルでなければなりません。
%
% C = CROSS(A,B) は、長さが3の最初の次元について、A と B の外積を出力
% します。
%
% C = CROSS(A,B,DIM) は、A と B がN次元配列のとき、ベクトル A と B の次元
% DIM の外積を出力します。A と B は同じサイズで、SIZE(A,DIM)とSIZE(B,DIM) 
% が共に3でなければなりません。
%
% 参考：DOT.


%   Clay M. Thompson
%   updated 12-21-94, Denise Chen
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:03 $
