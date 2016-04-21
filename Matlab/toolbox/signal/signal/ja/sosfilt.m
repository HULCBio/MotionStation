% SOSFILT は、2次 IIR フィルタを適用します。
%
% SOSFILT(SOS, X) は、2次構造フィルタ(SOS)をベクトル X に適用します。SOS
% の係数行列は、その行に各々の2次構造フィルタの係数を含んだ L 行6列の行
% 列です。X が行列の場合、SOSFILT は、X の各列にフィルタを適用します。
%
% SOSFILT は、フィルタリングの時に直接Ⅱ型フィルタを使います。
%
% 行列SOS は、以下の型でなければなりません。
%
%   SOS = [ b01 b11 b21 a01 a11 a21
%           b02 b12 b22 a02 a12 a22
%           ...
%           b0L b1L b2L a0L a1L a2L ]
%
% 参考：   LATCFILT, FILTER, TF2SOS, SS2SOS, ZP2SOS, SOS2TF, 
%          SOS2SS, SOS2ZP.



%   Copyright 1988-2002 The MathWorks, Inc.
