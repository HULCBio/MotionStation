% function [k,g,gfin,ax,ay,hamx,hamy] =
%         dhfsyn(p,nmeas,ncon,gmin,gmax,tol,h,z0,quiet,ricmethd,epr,epp)
%
% この関数は、離散時間システムPに対して、連続時間への双一次変化を使い、
% その後、NINFSYNEを呼び出すことによって、H∞(準)最適n状態コントローラを
% 計算します。システムPは、つぎのように分割されます。
%                        | a   b1   b2   |
%            p    =      | c1  d11  d12  |
%                        | c2  d21  d22  |
% ここで、b2は、制御入力の数からなる列サイズ(NCON)、c2は、コントローラに
% 与えられる観測数からなる行サイズ(NMEAS)です。z=z0で極値をもつエントロ
% ピー解を与えます。
%
% 入力:
%    P        -   制御設計のための相互結合行列(離散時間)
%    NMEAS    -   コントローラに入力される観測出力の数(np2)
%    NCON     -   制御出力数(nm2)
%    GMIN     -   gammaの下界
%    GMAX     -   gammaの上界
%    TOL      -   最終のgammaと1つ前のgammaとの差の許容範囲
%    H        -   サンプリング時間(デフォルト=1)
%    Z0       -   エントロピーが極値となる点(ABS(Z0)>1)(デフォルト Z0=inf)。
%                 ABS(Z0)>1の場合、すべての解は、gfinより小さいPhiのノル
%                 ムを使ったstarp(K,Phi)のように、KとGでパラメータ化され
%                 ます。
%    QUIET    -   スクリーン上の表示法
%                   1 - 表示なし
%                   0 - ヘッダなしの表示
%                  -1 - すべてを表示(デフォルト)
%    RICMETHD -   Riccati解
%                   1 - 固有値分解(平衡化付き)
%                  -1 - 固有値分解(平衡化なし)
%                   2 - 実schur分解(平衡化付き、デフォルト)
%                  -2 - 実schur分解(平衡化なし)
%    EPR      -   Hamiltonian行列の固有値の実数部がゼロかどうかの判定基
%                 準(デフォルト EPR = 1e-10)
%    EPP      -   x∞解が正定であるかどうかの判定基準(デフォルト EPP = 
%                 1e-6)
%
%  出力:
%    K       -   H∞コントローラ(離散時間)
%    G       -   閉ループシステム(離散時間)
%    GFIN    -   制御設計で使われる最終gamma値 
%    AX      -   独立変数gammaに関連したX-Riccati解をVARYING行列として
%                出力(オプション)	
%    AY      -   独立変数gammaに関連したY-Riccati解をVARYING行列として
%                出力(オプション)
%    HAMX    -   独立変数gammaに関連したX-Hamiltonian行列をVARYING行列
%                として出力(オプション)
%    HAMY    -   独立変数gammaに関連したY-Hamiltonian行列をVARYING行列
%                として出力(オプション)
%
% 参考: DHFNORM, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, 
%       RIC_SCHR, SDHFNORM, SDHFSYN, SDTRSP



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
