% SGRID   根軌跡または極 - 零点図用のs-平面グリッドラインを作成
% 
% SGRID は、既に存在している s-平面の根軌跡または極 - 零点図上にグリッド
% を作成します。減衰比や固有周波数を示すラインが描かれます。
% 
% SGRID('new') は、カレント軸をクリアし、HOLD ON 状態に設定します。
% 
% SGRID(Z,Wn) は、ベクトル Z の減衰比とベクトル Wn の固有周波数に対して、
% 減衰比と周波数が一定となるラインをプロットします。
% 
% SGRID(Z,Wn,'new') は、カレント軸をクリアし、HOLD ON 状態に設定します。
%
% 参考： RLOCUS, ZGRID, PZMAP.


%   Clay M. Thompson
%   Revised: ACWG 6-21-92, AFP 10-15-94
%   Revised: Adam DiVergilio, 12-99, , P. Gahinet 1-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:50 $
