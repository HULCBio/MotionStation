% ISOCOLORS は、等特性サーフェスとパッチカラーを計算します。
% 
% NC = ISOCOLORS(X,Y,Z,C,VERTICES) は、カラーベクトル C を使って、等特性
% サーフェス(パッチ)の頂点 VERTICES のカラーを計算します。配列 X,Y,Z は
% データ C を与える点を設定します。X,Y,Z は、C に対する座標で、単調ベクトル
% であるか、3次元格子配列である必要があります。カラーは、NC に出力され
% ます。C は3次元(インデックスカラー)でなければなりません。
% 
% NC = ISOCOLORS(X,Y,Z,R,G,B,VERTICES) は、R,G,B カラー配列を使用します。
%
% NC = ISOCOLORS(C,VERTICES) または 
% NC = ISOCOLORS(R,G,B,VERTICES)は、つぎのステートメントを仮定します。
% 
%    [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(C) です。 
% 
% NC = ISOCOLORS(C,P), NC = ISOCOLORS(X,Y,Z,C,P), NC = ISOCOLORS...
% (R,G,B,P), NC = ISOCOLORS(X,Y,Z,R,G,B,P) は、パッチ P からの頂点を
% 使用します。
% 
% ISOCOLORS(C,P), ISOCOLORS(X,Y,Z,C,P), ISOCOLORS(R,G,B,P), 
% ISOCOLORS(X,Y,Z,R,G,B,P) は、計算されたカラーを使って、P に設定された
% パッチの 'FaceVertexCdata' プロパティを設定します。
%
% 例題 1:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      cdata = smooth3(rand(size(data)), 'box', 7);
%      p = patch(isosurface(x,y,z,data, 10));
%      isonormals(x,y,z,data,p);
%      isocolors(x,y,z,cdata,p);
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);axis tight
%      camlight; lighting p; 
%
% 例題 2:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      p = patch(isosurface(x,y,z,data, 20));
%      isonormals(x,y,z,data,p);
%      [r g b] = meshgrid(20:-1:1, 1:20, 1:20);
%      isocolors(x,y,z,r/20,g/20,b/20,p);
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);
%      camlight; lighting p; 
%
% 例題 3:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      p = patch(isosurface(data, 20));
%      isonormals(data,p);
%      [r g b] = meshgrid(20:-1:1, 1:20, 1:20);
%      c=isocolors(r/20,g/20,b/20,p);
%      set(p, 'FaceVertexCdata', 1-c)
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);
%      camlight; lighting p; 
%
% 参考：ISOSURFACE, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH, ISONORMALS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:05:19 $
