% function [k,g,norms,kfi,gfi,hamx,hamy] = ...
%		h2syn(plant,nmeas,ncon,ricmethod,quiet)
%
% 線形分数相互結合構造Pに対して、H2最適コントローラ(K)と閉ループシステム
% (G)を計算します。NMEASとNCONは、Pからの制御出力の次元と、Pへの制御入力
% です。RICMETHOD は、Riccati方程式の解法に使用する手法を決定します。
%
% 入力:
%   PLANT     -   相互結合構造行列(SYSTEM行列) 
%   NMEAS     -   コントローラへの観測出力数
%   NCON      -   制御入力数
%   RICMETHOD -   Riccati方程式の解法
%                   1 - 固有値分解(平衡化付き)
%                  -1 - 固有値分解(平衡化なし)
%                   2 - 実schur分解(平衡化付き、デフォルト)
%                  -2 - 実schur分解(平衡化なし)
%   QUIET     -   X2とY2の最小固有値の表示
%		    0 - 結果を出力しません。
%		    1 - 結果をコマンドウィンドウに表示(デフォルト)
%
% 出力:
%   K         -  H2最適コントローラ
%   G         -  H2最適コントローラをもつ閉ループシステム
%   NORMS     -  4つの異なる量のノルム。全情報制御評価(FI)、出力推定評価
%                (OEF)、直接フィードバック評価(DFL)、全制御評価(FC)。
%                   norms = [FI OEF DFL FC];
%                   h2norm(g) = sqrt(FI^2 + OEF^2) = sqrt(DFL^2 + FC^2)
%   KFI       -  全情報/状態フィードバック制御則
%   GFI       -  全情報/状態フィードバック閉ループシステム
%   HAMX      -  X Hamiltonian行列
%   HAMY      -  Y Hamiltonian行列
%
% 参考: H2NORM, HINFSYN, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
