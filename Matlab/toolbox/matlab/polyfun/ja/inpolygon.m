% INPOLYGON   多角形内の点の検出
% 
% IN = INPOLYGON(X、Y、XV、YV) は、X や Y と同じサイズの行列 IN を出力
% します。ベクトル XV と YV で指定される頂点をもつ多角形内に点
% (X(p,q)、Y(p,q))がある場合は、IN(p,q) = 1です。点が多角形の境界上に
% ある場合は、IN(p,q) は0.5です。点が多角形の外にある場合は、
% IN(p,q) = 0です。
%
% [IN ON] = INPOLYGON(X,Y,XV,YV) は2つ目の行列 ON を出力します。
% これは、X と Y のサイズです。点(X(p,q), Y(p,q)) が多角形領域の端に
% ある場合は、ON(p,q) = 1 で、そうでない場合は、ON(p,q) = 0 です。
%
% 例題:
%       xv = rand(6,1); yv = rand(6,1);
%       xv = [xv ; xv(1)]; yv = [yv ; yv(1)];
%       x = rand(1000,1); y = rand(1000,1);
%       in = inpolygon(x,y,xv,yv);
%       plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
%   入力 X,Y,XV,YV のサポートクラス
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.