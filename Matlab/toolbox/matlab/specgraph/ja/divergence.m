% DIVERGENCE は、ベクトル場の Divergence を計算します。
% 
% DIV = DIVERGENCE(X,Y,Z,U,V,W) は、3次元ベクトル場 U,V,W の Divergence 
% を計算します。配列 X,Y,Z は、U,V,W に対する座標を定義し、単調で、
% (MESHGRID で作成するように)3次元格子でなければなりません。
% 
% DIV = DIVERGENCE(U,V,W) は、つぎのステートメントを仮定しています。
% 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N] = SIZE(U) です。 
%
% DIV = DIVERGENCE(X,Y,U,V) は、2次元のベクトル場、U,V の Divergence を
% 計算します。配列 X,Y は、U,V に対する座標を定義し、単調で、(MESHGRID 
% で作成するように)2次元格子でなければなりません。
% 
% DIV = DIVERGENCE(U,V) は、つぎのステートメントを仮定しています。
% 
%         [X Y] = meshgrid(1:N, 1:M) 
% 
% ここで、[M,N,P] = SIZE(U) です。 
% 
% 例題 :
%      load wind
%      div = divergence(x,y,z,u,v,w);
%      slice(x,y,z,div,[90 134],[59],[0]); shading interp
%      daspect([1 1 1])
%      camlight
%
% 参考：STREAMTUBE, CURL, ISOSURFACE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:04:54 $
