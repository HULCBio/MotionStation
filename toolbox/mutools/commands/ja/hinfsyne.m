% function [k,g,gfin,ax,ay,hamx,hamy] = ....
%      hinfsyne(p,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp)
%
% この関数は、システムPに対して、H∞(準)最適n状態制御則を計算します。
% Glover and Doyleの論文(1988)の結果を使います。システムPは、つぎの形式
% です。
%                        | a   b1   b2   |
%            p    =      | c1  d11  d12  |
%                        | c2  d21  d22  |
% ここで、b2は、制御入力の数からなる列サイズ(NCON)、c2は、コントローラに
% 与えられる観測数からなる行サイズ(NMEAS)です。s = s0で極値をもつエント
% ロピー解を与えます。
%
% 入力:
%   P        -  制御設計のための相互結合行列
%   NMEAS    -  コントローラに入力される観測出力の数(np2)
%   NCON     -  コントローラ出力数(nm2)
%   GMIN     -  gammaの下界
%   GMAX     -  gammaの上界
%   TOL      -  最終のgammaと1つ前のgammaとの差の許容範囲
%   S0       -  エントロピーが極値となる点(>0)(デフォルト S0=inf)。S0<=0
%               の場合、すべての解はgfinより小さいPhiのノルムを使ったst-
%               arp(K,Phi)のようにKとGで、パラメータ化されます。
%   QUIET    -  スクリーン上の制御の表示
%                  1 - 表示なし
%                  0 - ヘッダなしの表示
%                 -1 - すべてを表示(デフォルト)
%   RICMETHD -  Riccati方程式の解法
%                  1 - 固有値分解(平衡化付き)
%                 -1 - 固有値分解(平衡化なし)
%                  2 - 実schur分解(平衡化付き、デフォルト)
%                 -2 - 実schur分解(平衡化なし)
%   EPR      -  Hamiltonian行列の固有値の実数部がゼロかどうかの判定基準
%               (デフォルト EPR = 1e-10)
%   EPP      -  x∞解が正定であるかどうかの判定基準
%               (デフォルト EPP = 1e-6)
%
%  出力:
%   K       -  H∞コントローラ
%   G       -  閉ループシステム
%   GFIN    -  制御設計で使われた最終gamma値 
%   AX      -  独立変数gammaに関連したX-Riccati解をVARYING行列として出力
%              (オプション)
%   AY      -  独立変数gammaに関連したY-Riccati解をVARYING行列として出力
%              (オプション)
%   HAMX    -  独立変数gammaに関連したX-Hamiltonian行列をVARYING行列とし
%              て出力(オプション)
%   HAMY    -  独立変数gammaに関連したY-Hamiltonian行列をVARYING行列とし
%              て出力(オプション)
%
% 参考: DHFSYN, H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR,
%       SDHFNORM, SDHFSYN



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
