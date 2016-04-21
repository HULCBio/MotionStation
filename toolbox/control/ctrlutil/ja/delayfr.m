% DELAYFR   連続系の遅れをもつシステムの周波数応答
%
% G = DELAYFR(DT,S) は、純粋に I/O の遅れが DT をもつ連続時間 LTI モデル
% の複素周波数ベクトル S での周波数応答を計算します。
%
%    y(1) = exp(-s*DT(1,1))*u(1) + exp(-s*DT(1,2))*u(2) + ...
%    y(2) = exp(-s*DT(2,1))*u(1) + exp(-s*DT(2,2))*u(2) + ...
%      ...
%
% 行列 DT は、各入/出力の組に対する遅れ時間を設定します。NY 出力、NU 
% 入力、NW の周波数点の場合、出力 G は、NY x NU x NW の大きさの配列に
% なります。
%
% 参考 : FREQRESP.


%    Author: P. Gahinet, 7-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:31 $
