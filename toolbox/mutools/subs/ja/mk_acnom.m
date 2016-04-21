%------------------------- mk_acnom ------------------------%
% これは、SSLAFCS用の戦闘機モデルを作成します。SYSTEM行列は、つぎのもの
% を作成します。
%
% ACNOM:  4状態、7出力、6入力
%
%      出力:	                      入力:
% 1) pert1o                      1) pert1i
% 2) pert2o                      2) pert2i
% 3) pert3o  	                 3) pert3i
% 4) p (ロール変化率(rad/s))	 4) theta_el  (補助翼角(rad))
% 5) r (ヨー変化率(rad/s))	 5) theta_rud (方向舵角(rad))
% 6) ny (加速度(ft/s^2))	 6) gust disturbance (ft/s)
% 7) phi (横傾斜角(rad))
%

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:22 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
