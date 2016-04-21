% STREAMRIBBON は、3次元のストリームリボンを作成します。
% 
% STREAMRIBBON(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) は、ベクトルデータ 
% U,V,W からストリームリボンを描画します。配列 X,Y,Z は、U,V,W の座標を
% 指定するもので、単調で(MESHGRID を使って作成した)3次元の格子でなければ
% なりません。STARTX,STARTY,STARTZ は、リボンの中心で、ストリームラインの
% 出発点を定義します。リボンの捻じれ(ツイスト)は、ベクトル場のCurl の
% 度合いに比例します。リボンの幅は、自動的に計算されます。通常、STREAMRIBBON 
% をコールする前に、DataAspectRatio を設定することが望まれます。
% 
% STREAMRIBBON(U,V,W,STARTX,STARTY,STARTZ) は、つぎのステートメントを
% 仮定しています。 
% 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(U)です。 
% 
% STREAMRIBBON(VERTICES,X,Y,Z,CAV,SPEED) は、ストリームラインの頂点、
% Curl 角速度、流速を前もって計算していることを仮定しています。VERTICES
% は、(関数 stream3 で作成した)ストリームラインの頂点のセル配列です。
% X,Y,Z,CAV,SPEED は、3次元配列です。
%
% STREAMRIBBON(VERTICES,CAV,SPEED) は、つぎのステートメントを仮定して
% います。
% 
%      [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(CAV)です。
%
% STREAMRIBBON(VERTICES,TWISTANGLE) は、ベクトル TWISTANGLE のセル配列
% を使って、リボンの捻じれ(ラジアン単位)を設定します。VERTICES と 
% TWISTANGLE の各対応する要素の大きさは、同じである必要があります。
%
% STREAMRIBBON(...,WIDTH) は、リボンの幅を WIDTH で設定します。 
%
% STREAMRIBBON(AX,...) は、GCAの代わりにAXにプロットします。  
%
% H = STREAMRIBBON(...) は、SURFACE オブジェクトに(出発点に関して1つの)
% ハンドルからなるベクトルを出力します。
%
% 例題 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      h = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% 例題 2:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      cav = curl(x,y,z,u,v,w);
%      spd = sqrt(u.^2 + v.^2 + w.^2);
%      h = streamribbon(verts,x,y,z,cav,spd);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% 例題 3:
%      t = 0:.15:15;
%      verts = {[cos(t)' sin(t)' (t/3)']};
%      twistangle = {cos(t)'};
%      daspect([1 1 1])
%      h = streamribbon(verts,twistangle);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% 例題 4:
%     xmin = -7; xmax = 7;
%     ymin = -7; ymax = 7; 
%     zmin = -7; zmax = 7; 
%     x = linspace(xmin,xmax,30);
%     y = linspace(ymin,ymax,20);
%     z = linspace(zmin,zmax,20);
%     [x y z] = meshgrid(x,y,z);
%     u = y; v = -x; w = 0*x+1;
%     
%     daspect([1 1 1]); 
%     [cx cy cz] = meshgrid(linspace(xmin,xmax,30),....
%           linspace(ymin,ymax,30),[-3 4]);
%     h2 = coneplot(x,y,z,u,v,w,cx,cy,cz, 'q');
%     set(h2, 'color', 'k');
%     
%     [sx sy sz] = meshgrid([-1 0 1],[-1 0 1],-6);
%     p = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%     [sx sy sz] = meshgrid([1:6],[0],-6);
%     p2 = streamribbon(x,y,z,u,v,w,sx,sy,sz);
%     shading interp
%     
%     view(-30,10) ; axis off tight
%     camproj p; camva(66); camlookat; camdolly(0,0,.5,'f')
%     camlight
%
% 参考：CURL, STREAMTUBE, STREAMLINE, STREAM3.


%   Copyright 1984-2002 The MathWorks, Inc. 
