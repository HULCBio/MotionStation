% function [k,g,gfin,ax,hamx] = hinffi(p,ncon,gmin,gmax,tol,ricmethd,epr,epp)
%
% この関数は、システムPに対して、全情報H∞n状態コントローラを計算します。
% Glover and Doyleの論文(1988)の結果を使います。解は、すべての状態と外乱
% が測定できると仮定します。行列Pは、つぎの形式です。
%
%     p  =  | ap  | b1   b2  |
%           | c1  | d11  d12 |
%
% 全情報コントローラをもつ閉ループを作るときには、注意が必要です。フィー
% ドバックに対して、相互結合構造Pは、状態と外乱の観測量をもつように拡大
% されなければなりません。
%
% 入力:
%    P        -   制御設計用の相互結合行列
%    NCON     -   コントローラ出力数(nm2)
%    GMIN     -   gammaの下界
%    GMAX     -   gammaの上界
%    TOL      -   最終のgammaと1つ前のgammaとの違いの許容範囲
%    RICMETHD - Ricatti方程式の解法
%                   1 - 固有値分解(平衡化付き)
%                  -1 - 固有値分解(平衡化なし)
%                   2 - 実schur分解(平衡化付き、デフォルト)
%                  -2 - 実schur分解(平衡化なし)
%    EPR      -   Hamiltonian行列の固有値の実数部がゼロかどうかの判定基
%                 準(デフォルト EPR = 1e-10)
%    EPP      -   x∞解が正定行列であるかどうかの判定基準(デフォルト 
%                 EPP = 1e-6)
%
% 出力:
%    K        -   H∞全情報コントローラ
%    G        -   閉ループシステム
%    GFIN     -   制御設計に使われる最終のgamma値 
%    AX       -   独立変数gammaに関連したRiccati解をVARYING行列として出
%                 力(オプション)
%    HAMX     -   独立変数gammaに関連したHamiltonian行列をVARYING行列と
%                 して出力(オプション)



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
