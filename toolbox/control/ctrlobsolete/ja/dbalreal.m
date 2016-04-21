% DBALREAL   離散の平衡化された状態空間の実現とモデルの低次元化
%
% [Ab,Bb,Cb] = DBALREAL(A,B,C) は、システム(A, B, C) の平衡化された状態
% 空間実現を出力します。
%
% [Ab,Bb,Cb,M,T] = DBALREAL(A,B,C) は、システム (A, B, C) を (Ab,Bb,Cb) 
% に変換する際に使用する相似変換行列 T と平衡化実現のグラミアンの対角部を
% 含んだベクトル M を出力します。システム(A, B, C)が、適切に正規化されて
% いる場合、グラミアン M の中の小さな要素は、モデルを低次元にするために、
% 除去することができます。
%
% 参考 : DMODRED, BALREAL and MODRED.


%   J.N. Little 3-6-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:34 $
