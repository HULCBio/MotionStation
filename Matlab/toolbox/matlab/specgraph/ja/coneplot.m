% CONEPLOT   3次元円錐プロット
% 
% CONEPLOT(X,Y,Z,U,V,W,Cx,Cy,Cz) は、U,V,W で定義されたベクトルフィールド
% 内の点 (Cx,Cy,Cz) で、速度ベクトルを円錐形としてプロットします。配列 
% X,Y,Z は、U,V,W に対する座標を定義し、(MESHGRID で出力されるように)
% 単調で3次元格子形でなければなりません。CONEPLOT は、円錐形を画面に
% 合うように自動的にスケーリングします。CONEPLOT を呼び出す前に、
% DataAspectRatio を設定するのが、通常最も良い結果を得ます。
% 
% CONEPLOT(U,V,W,Cx,Cy,Cz) は、[M,N,P] = SIZE(U) のとき、
% [X Y Z] = meshgrid(1:N,1:M,1:P) と仮定します。
% 
% CONEPLOT(...,S) は、画面に合うように自動的に円錐形をスケーリングし、
% その結果を S だけ伸ばします。自動スケーリングを行わずに円錐形をプロット
% するには、S = 0 を使用してください。
% 
% CONEPLOT(...,COLOR) は、配列 COLOR を使って、円錐に色付けします。
% COLORは3次元配列で、U と同じサイズです。このオプションは、円錐と共に
% 機能し、ベクトルを示す矢印とは機能しません。
% 
% CONEPLOT(...,'quiver') は、円錐形の代わりに矢印を描画します(QUIVER3 を
% 参照)。
%
% CONEPLOT(...,'method') は、使用する補間法を設定します。'method' は、
% 'linear'、'cubic'、'nearest' のいずれかです。'linear' はデフォルトです
% (INTERP3 を参照)。
% 
% CONEPLOT(X,Y,Z,U,V,W, 'nointerp') は、円錐の位置を物体内に内挿しません。
% 円錐は、X, Y, Z で定義される位置に描画され、U, V, W に従った方向を
% 向いています。配列 X, Y, Z, U, V, W は、同じサイズでなければなりません。
% 
% CONEPLOT(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = CONEPLOT(...) は、PATCH のハンドルを出力します。
% 
% 例題:
%      load wind
%      vel = sqrt(u.*u + v.*v + w.*w);
%      p = patch(isosurface(x,y,z,vel, 40));
%      isonormals(x,y,z,vel, p)
%      set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
%
%      daspect([1 1 1]);   % coneplotは、始めに DataAspectRatio を設定して
%                          % おくと、良い結果が得られます。
%      [f verts] = reducepatch(isosurface(x,y,z,vel, 30), .2); 
%      h=coneplot(x,y,z,u,v,w,verts(:,1),verts(:,2),verts(:,3),2);
%      set(h, 'FaceColor', 'blue', 'EdgeColor', 'none');
%      [cx cy cz] = meshgrid(linspace(71,134,10),
%      linspace(18,59,10),3:4:15);
%      h2=coneplot(x,y,z,u,v,w,cx,cy,cz,v,2); 
%      set(h2, 'EdgeColor', 'none');
%
%      axis tight; box on
%      camproj p; camva(24); campos([185 2 102])
%      camlight left; lighting phong
%
% 参考：STREAMLINE, STREAM3, STREAM2, ISOSURFACE, SMOOTH3, SUBVOLUME,
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
