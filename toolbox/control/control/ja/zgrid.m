% ZGRID   根軌跡または極 - 零点図用のz-平面グリッドラインを作成
% 
% ZGRID は、既に存在している z-平面の根軌跡または極 - 零点図上にグリッド
% を作成します。減衰比や固有周波数を示すラインが、z 平面の単位円内に描か
% れます。
% 
% カレントフィギュアに何も表示されていない場合、ZGRID は、z-平面グリッド
% をプロットし、HOLD ON の状態にして、根軌跡または極 - 零点図をグリッド
% 上に重ね書きします。
%
% ZGRID(Z,Wn) は、ベクトル Z の減衰比とベクトル Wn の固有周波数に対して、
% 減衰比と周波数が一定となるラインをプロットします。ZGRID(Z,Wn,'new') は、
% 最初にスクリーン内の画面を消去します。
%
% 参考: RLOCUS, SGRID, PZMAP.


%   Marc Ullman   May 27, 1987
%   Revised: JNL 7-10-87, CMT 7-13-90, ACWG 6-21-92
%   Revised: Adam DiVergilio, 12-99, P. Gahinet 1-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:58 $
