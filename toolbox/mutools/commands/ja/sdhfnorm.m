%function [gaml,gamu]=sdhfnorm(sdsys,k,h,delay,tol);
%
% この関数は、理想のサンプラとゼロ次ホールドを通じて結合された離散時間
% SYSTEM行列とのフィードバックにおいて、連続系SYSTEM行列のL2誘導ノルム
% を計算します。
%
% 連続時間プラントSDSYSは、つぎのように分割されます。
%                        | a   b1   b2   |
%            sdsys    =  | c1   0    0   |
%                        | c2   0    0   |
%
% dは、ゼロでなければなりません。
%
% 入力:
%   SDSYS  - 連続時間SYSTEM行列(プラント)
%   K      - 離散時間行列(コントローラ)
%   H      - コントローラKのサンプリング周期
%   DELAY  - コントローラの計算上の遅れを与える非負の整数(デフォルト 0)
%   TOL    - 検索の終了時の上界と下界の間の差(デフォルト 0.001)
% 出力:
%   GAMU   - ノルムの上界
%   GAML   - ノルムの下界
%
%
%	                _________
%	               |         |
%	     z <-------|  sdsys  |<-------- w
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
%       RIC_EIG, RIC_SCHR, SDTRSP, SDHFNORM.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
