% PADECOEF   むだ時間のPade近似
%
% [NUM,DEN] = PADECOEF(T,N) は、連続系遅延 exp(-T*s) のN次のPade近似
% を伝達関数型で出力します。行ベクトル NUM と DEN は、s の降べき順に
% 多項式係数を含みます。
%
% 入力 T のサポートクラス
%      float: double, single
%
% 参考 PADE

%   Copyright 1984-2004 The MathWorks, Inc.
