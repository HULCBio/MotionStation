% function [k,g,gfin,ax,ay,hamx,hamy] = ....
%           hinfsyn(p,nmeas,ncon,gmin,gmax,tol,ricmethd,epr,epp,quiet)
%
% この関数は、システムPに対して、H∞(準)最適n状態制御則を計算します。
% Glover and Doyleの論文(1988)の結果を使います。Pは、つぎのようになりま
% す。
%                        | a   b1   b2   |
%            p    =      | c1  d11  d12  |
%                        | c2  d21  d22  |
% ここで、b2は、制御入力の数からなる列サイズ(NCON)、c2は、コントローラに
% 与えられる観測数からなる行サイズ(NMEAS)です。
%
% 入力:
%   P        -  制御設計用の相互結合行列
%   NMEAS    -  コントローラへ入力される観測出力の数(np2)
%   NCON     -  コントローラの出力数(nm2)
%   GMIN     -  gammaの下界
%   GMAX     -  gammaの上界
%   TOL      -  最終のgammaと1つ前のgammaとの差の許容範囲
%   RICMETHD -  Riccati方程式の解法
%                  1 - 固有値分解(平衡化付き)
%                 -1 - 固有値分解(平衡化なし)
%                  2 - 実schur分解(平衡化付き、デフォルト)
%                 -2 - 実schur分解(平衡化なし)
%   EPR      -  Hamiltonian行列の固有値の実数部がゼロかどうかの判定基準
%               (デフォルト EPR = 1e-10)
%   EPP      -  x∞解が正定であるかどうかの判定基準
%               (デフォルト EPP = 1e-6)
%   QUIET    -  H∞イタレーションに関する情報の表示
%                  0 - 結果を表示しません。
%                  1 - 結果をコマンドウィンドウに表示(デフォルト)
%
%  出力:
%    K       -   H∞コントローラ
%    G       -   閉ループシステム
%    GFIN    -   制御設計で使われた最終gamma値 
%    AX      -   独立変数gammaに関連したX-Riccati解をVARYING行列として出
%                力(オプション)
%    AY      -   独立変数gammaに関連したY-Riccati解をVARYING行列として出
%                力(オプション)
%    HAMX    -   独立変数gammaに関連したX-Hamiltonian行列をVARYING行列と
%                して出力(オプション)
%    HAMY    -   独立変数gammaに関連したY-Hamiltonian行列をVARYING行列と
%                して出力(オプション)
%
% 参考: H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
