% NGRID   Nichols 線図用のグリッドラインを作成
%
% NGRID は、NICHOLS で作成された Nichols 線図上に Nichols 線図のグリッド
% をプロットします。Nichols 線図は、H/(1+H) が(複素平面内で H が変化する)
% 一定のゲインと位相である、複素数 H と H/(1+H) とラインの変化を関連
% 付けます。
%
% NGRID('new') は、カレント軸をクリアして、HOLD ON 状態にします。
%
% NGRID は、カレント軸内にプロットが存在していない場合、大きさは-40 dB 
% から 40 dB の範囲、位相は-360 度から0度の範囲で、グリッドを作成します。
%
% NGRID は、SISO システムでのみ使用できます。
%
% 参考：   NICHOLS.


%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:33 $
