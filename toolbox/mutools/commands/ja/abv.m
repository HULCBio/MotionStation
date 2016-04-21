% function out = abv(mat1,mat2,mat3...,matN,[memstr])
%
% VARYING/SYSTEM/CONSTANT行列を上から順に結合します。
%
%                        |  mat1  |
%                        |  mat2  |
%          out    =      |  mat3  |
%                        |   ..   |
%                        |  matN  |
%
% memstrは、コマンドの実行において、メモリの使用量を最小化するかどうかを
% 設定する文字列変数です。memstr = "min_mem"の場合、VARYING行列はforルー
% プ内にスタックされます。これにより、実行は、より遅くなりますが、メモリ
% 使用量が小さくなります。メモリが限られているマシン上で巨大な実験データ
% を取り扱うときに、この機能を使います。
%
% 参考: MADD, DAUG, MMULT, SBS, SEL, VDIAG.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
