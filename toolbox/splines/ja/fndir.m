% FNDIR   関数の方向微分
%
% FNDIR(F,DIRECTION) は、F に含まれる(そして同じ次数の)関数の DIRECTION 
% 方向の微分(のpp-型)を出力します。
% F にあるがm変数の場合、DIRECTION は、m要素のベクトル(のリスト)、すな
% わち、ある nd に対して大きさ [m,nd] でなければなりません。
%
% F にある関数が、m変数でd個の値をもつと仮定すると、FDIR は(prod(d)*nd)個
% の値をもつ関数を記述します。点 X におけるその関数の値 V は、大きさ 
% [d,nd] の配列として整形されており、そのj番目の'列' V(:,j) に対して、
% 点 X における F にある関数の DIRECTION(:,j) 方向(j=1:nd)の微分を与え
% ます。
% 出力される関数が、F のターゲットの次元を完全に反映することを求める
% 代わりに以下の方法を使用してください。
%
%      fdir = fnchg( fndir(f,direction), ...
%                    'dim',[fnbrk(f,'dim'),size(direction,2)] );
%
% FNDIR は、有理スプラインに対しては機能しません。代わりに FNTLR を使用
% してください。
%
% 例題: f がm変数でd要素のベクトル値の関数を記述し、x が領域内のいくつ
%       かの点である場合、
%
%      reshape(fnval(fndir(f,eye(d)),x),d,m)
%
% は、その点での関数のヤコビアンです。関連する例として、つぎのステート
% メントでは、標準のメッシュでのFranke関数(への適切な近似)の勾配を
% プロットします。
%
%    xx = linspace(-.1,1.1,13); yy = linspace(0,1,11);
%    [x,y] = ndgrid(xx,yy); z = franke(x,y);
%    pp2dir = fndir(csapi({xx,yy},z),eye(2));
%    grads = reshape(fnval(pp2dir,[x(:) y(:)].'),[2,length(xx),length(yy)]);
%    quiver(x,y,squeeze(grads(1,:,:)),squeeze(grads(2,:,:)))
%
% 参考 : FNDER, FNTLR, FNINT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
