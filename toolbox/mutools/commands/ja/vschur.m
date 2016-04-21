% function [u,t] = vschur(mat)
%
% VARYING/CONSTANT行列のSchur分解を計算します。MATLABのSCHURコマンドと同
% じですが、VSCHURはVARYING行列に対しても機能します。
%   入力:
%	     MAT - VARYING/CONSTANT行列
%   出力:
%	     U   - ユニタリなVARYING/CONSTANT行列。
%                  MAT = MMULT(U,T,TRANSP(U))とMMULT(TRANSP(U),U)は、対
%                  応するタイプの単位行列です。
%            T   - 入力のVARYING/CONSTANT行列によって、複素Schur型または
%                  実Schur型。
%
% 参考: CSORD, EIG, RSF2CSF, SCHUR, SVD, VEIG, VSVD.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
