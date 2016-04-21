% QUIVER3   3次元quiverプロット
% 
% QUIVER3(X,Y,Z,U,V,W) は、点(x,y,z)で成分(u,v,w)をもつ矢印として、速度
% ベクトルをプロットします。行列 X,Y,Z,U,V,W は、すべて同じサイズで、
% 対応する位置と速度成分を含まなければなりません。QUIVER3 は、自動的に
% 矢印をスケーリングします。
%
% QUIVER3(Z,U,V,W) は、行列Zで指定された等間隔のサーフェス上の点に、
% 速度ベクトルをプロットします。
%
% QUIVER3(Z,U,V,W,S) または QUIVER3(X,Y,Z,U,V,W,S) は、矢印を自動的に
% スケーリングし、その後それらを S 倍に拡大します。自動スケーリングを
% 行わずに矢印をプロットするためには、S = 0を使ってください。
%
% QUIVER3(...,LINESPEC) は、速度ベクトルに対して指定されたラインスタイル
% を使用します。矢印の先端の代わりに、LINESPEC のマーカが描画されます。
% マーカを設定しないようにするには、'.' を使用してください。使用可能な
% 他の値については、PLOT を参照してください。
%
% QUIVER3(...,'filled') は、指定したマーカを塗りつぶします。
%
% QUIVER3(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = QUIVER3(...) は、lineオブジェクトのハンドル番号からなるベクトルを
% 出力します。
%
% 例題:
%       [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%       z = x .* exp(-x.^2 - y.^2);
%       [u,v,w] = surfnorm(x,y,z);
%       quiver3(x,y,z,u,v,w); hold on, surf(x,y,z), hold off
%
% 参考：QUIVER, PLOT, PLOT3, SCATTER.


%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
