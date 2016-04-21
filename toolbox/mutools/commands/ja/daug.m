% function out = daug(mat1,mat2,mat3...,matN,[memstr])
%
% SYSTEM/VARYING/CONSTANT行列を対角に拡大します。入力行列は、最大9個に制
% 限されています。
%
%          |  mat1  0     0    .   0   |
%          |   0   mat2   0    .   0   |
%    out = |   0    0    mat3  .   0   |
%          |   .    .     .    .   .   |
%          |   0    0     0    .  matN |
%
% memstrは、コマンドの実行においてメモリの使用量を最小化するかどうかを設
% 定する文字列変数です。memstr = "min_mem"の場合、VARYING行列はforループ
% 内にスタックされます。これにより、実行はより遅くなりますが、メモリ使用
% 量が小さくなります。メモリが限られているマシン上で巨大な実験データを取
% り扱うときに、この機能を使います。
%
% 参考: ABV, MADD, MMULT, SBS, SEL, VDIAG



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
