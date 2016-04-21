% SYMRCM 　　対称逆Cuthill-McKeeでの並べ替え
% 
% p = SYMRCM(S) は、S(p,p) が、S よりも対角に対角要素をもつような置換
% ベクトル p を出力します。これは、"細長い"問題から生じる行列のLU分解
% または Cholesky分解に対して、良い並べ替えを行います。並べ替えは、S が
% 対称でも非対称でも行われます。
%
% 参考：SYMMMD, COLMMD, COLPERM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:43 $
