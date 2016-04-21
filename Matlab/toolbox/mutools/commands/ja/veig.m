% function  eval = veig(mat1,mat2)
% または
% function  [evect,eval] = veig(mat1,mat2)
%
% VARYING行列の固有値分解を行います。
%   入力:
%          mat1  - 正方なCONSTANT/VARYING行列
%          mat2  - 正方なCONSTANT/VARYING行列(オプション)
%   出力:
%          eval  - CONSTANT/VARYING行列MAT1の固有値を含むベクトル
%          evect - CONSTANT/VARYING行列MAT1の固有値を含むフル行列
%
% MAT2を与えると、一般化固有値問題を解きます。
%
% 参考: EIG, INDVCMP, SVD, VEBE, VPOLY, VROOTS, VSVD, VEVAL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
