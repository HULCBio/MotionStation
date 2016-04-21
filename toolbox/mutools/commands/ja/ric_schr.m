% function [x1,x2,fail,reig_min,epkgdif] = ric_schr(ham,epp,balflg)
%
% Riccati方程式の安定化解(A+R*Xが安定)に関連する固有値問題を解きます。
%
%        A'*X + X*A + X*R*X - Q = 0
%
% 実Schur分解は、Hamilton行列HAMの安定な不変部分空間を得るために使われま
% す。この行列は、つぎの形式の変数をもちます。
%
%        HAM = [A  R; Q  -A']
%
% HAMがjw軸上に固有値をもっていない場合、n行n列の行列x1とx2が存在します。
% これらの行列[ x1 ; x2 ]は、HAMのn次元の安定な不変部分空間です。x1が正
% 則な場合、X := x2/x1はRiccati方程式を満足し、その結果のA+RXは安定にな
% ります。出力フラグFAILは通常0です。jw軸上に固有値をもつ場合、FAILに1が
% 出力されます。正と負の固有値の数が同数でなければ、FAILには2が出力され、
% これらの条件が共に生じるときには、FAIL には3が出力されます。
%
% RIC_SCHRは、順序付けられた複素Schur型を作成するため、CSORDを呼び出しま
% す。この型を実Schur型に変換し、希望するHamiltonianの安定な不変部分空間
% を与えます。固有値の最小実数部の絶対値は、REIG_MINに出力されます。
%
% BALFLGは、Riccati方程式を解く前にHAMを平衡化するかどうかを指定するフラ
% グです。BALFLGを0に設定するとHAMを平衡化し、1に設定すると平衡化しませ
% ん。デフォルトでは、BALFLGは0に設定されます。EPKGDIFは、2つの異なるjw
% 軸のテストの比較です。
%
% 参考: CSORD, HAMCHK, RIC_EIG, SCHUR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
