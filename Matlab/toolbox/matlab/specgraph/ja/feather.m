% FEATHER   フェザープロット
% 
% FEATHER(U,V) は、横軸に沿った等間隔の点から出力される矢印として、U と 
% V の成分をもつ速度ベクトルをプロットします。FEATHER は、パスに沿って
% 選択された方向と強度データを表示するのに便利です。
%
% FEATHER(Z) は、複素数 Z に対して、FEATHER(REAL(Z),IMAG(Z)) と同じです。
% FEATHER(...,'LineSpec') は、'LineSpec' で指定したカラーとラインスタイル
% を使用します(使用可能な値についてはPLOT を参照)。
%
% FEATHER(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = FEATHER(...) は、lineオブジェクトのハンドル番号からなるベクトルを
% 出力します。
%
% 例題:
%      theta = (-90:10:90)*pi/180; r = 2*ones(size(theta));
%      [u,v] = pol2cart(theta,r);
%      feather(u,v), axis equal
%
% 参考：COMPASS, ROSE, QUIVER.


%   Charles R. Denham, MathWorks 3-20-89
%   Modified 1-2-92, ls.
%   Modified 12-7-93 Mark W. Reichelt
%   Copyright 1984-2002 The MathWorks, Inc. 
