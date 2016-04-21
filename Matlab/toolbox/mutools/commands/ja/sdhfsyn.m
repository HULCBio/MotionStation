%function [k,gfin] = sdhfsyn(sdsys,nmeas,ncon,.....
%                 gmin,gmax,tol,h,delay,ricmethd,epr,epp,quiet)
%
% この関数は、サンプル値データシステムに対してH∞(準)最適n状態離散時間コ
% ントローラを計算します。Bamieh and Pearson '92の結果を使って、初期問題
% は形態的に離散時間に変換されます。離散時間問題は、連続系に双一次的にマ
% ップされます。このとき、Glover and Doyleの論文(1988)の結果が使われます。
%
% 連続時間プラントSDSYSは、つぎのように分割されます。
%                        | a   b1   b2   |
%            sdsys    =  | c1   0    0   |
%                        | c2   0    0   |
% ここで、b2は、制御入力の数からなる列サイズ(NCON)、c2は、コントローラに
% 与えられる観測数からなる行サイズ(NMEAS)です。dはゼロでなければなりませ
% ん。
%
% 入力:
%   SDSYS    -  制御設計のための相互結合行列(連続時間)
%   NMEAS    -  コントローラに入力される観測出力の数(np2)
%   NCON     -  コントローラ出力数(nm2)
%   GMIN     -  gammaの下界(0より大きくなければなりません)
%   GMAX     -  gammaの上界
%   TOL      -  最終のgammaと1つ前のgammaとの差の許容範囲
%   H        -  設計されるコントローラのサンプリング周期
%   DELAY    -  コントローラの計算上の遅れを与える非負の整数(デフォルト
%               は0)
%   RICMETHD -  Riccati方程式の解法
%                 1 - 固有値分解(平衡化付き)
%                -1 - 固有値分解(平衡化なし)
%                 2 - 実schur分解(平衡化付き、デフォルト)
%                -2 - 実schur分解(平衡化なし)
%   EPR      -  Hamiltonian行列の固有値の実数部がゼロかどうかの判定基準
%               (デフォルト EPR = 1e-10)
%   EPP      -  x∞解が正定であるかどうかの判定基準
%               (デフォルト EPP = 1e-6)
%   QUIET    -  サンプルデータのH∞イタレーションの情報の表示
%                0 - 結果を表示しません。
%                1 - 結果をコマンドウィンドウに表示します(デフォルト)。
%
% 出力:
%   K        -  H∞コントローラ(離散時間)
%   GFIN     -  制御設計で使われる最終gamma値 
%
%	                _________
%	               |         |
%	       <-------|  sdsys  |<--------
%	               |         |
%	      /--------|_________|<-----\
%	      |       __  		 |
%	      |      |d |		 |
%	      |  __  |e |   ___    __    |
%	      |_|S |_|l |__| K |__|H |___|
%	        |__| |a |  |___|  |__|
%	             |y |
%	             |__|
%
% 参考: DHFNORM, DHFSYN, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM,
%       RIC_EIG, RIC_SCHR, SDTRSP, SDHFNORM



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
