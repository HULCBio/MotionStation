% function [x1,x2,fail,reig_min,epkgdif] = ric_eig(ham,epp,balflg)
%
% Riccati方程式の安定化解(A+R*Xが安定)に関連する固有値問題を解きます。
%
%       A'*X + X*A + X*R*X - Q = 0
%
% 固有値分解は、Hamiltonian行列HAMの安定な不変部分空間を得るために使われ
% ます。この行列は、つぎの形式の変数をもちます。
%
%      HAM = [A  R; Q  -A']
%
% HAMがjw軸上に固有値をもっていない場合、n行n列の行列X1とX2が存在します。
% これらの行列[ X1 ; X2 ]は、HAMのn次元の安定な不変部分空間です。X1が正
% 則な場合、X = X2/X1はRiccati方程式を満足し、その結果のA+RXは安定になり
% ます。HAMがjw軸上に固有値をもつ場合、FAILに1が出力されます。固有値の実
% 数部の大きさがEPPより小さければ、固有値は純虚数と考えます。固有値の最
% 小実数部は、REIG_MINに出力されます。EPPのデフォルト値は1e-10です。
%
% BALFLGは、Riccati方程式を解く前にHAMを平衡化するかどうかを指定します。
% BALFLGを0に設定するとHAMを平衡化し、BALFLGを非ゼロに設定すると平衡化し
% ません。デフォルトでは、BALFLGは0に設定されます。
%
% このコマンドは、HAMが対角化されない場合、不正確な結果になります。この
% 場合は、RIC_SCHRを使うことをお薦めします。EPKGDIFは、2つの異なるjw軸の
% テストの比較です。
%
% 参考: EIG, RIC_SCHR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
