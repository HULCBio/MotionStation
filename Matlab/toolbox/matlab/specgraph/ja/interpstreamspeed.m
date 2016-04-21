% INTERPSTREAMSPEED  スピードの観点からストリームラインの頂点を内挿
% 
% INTERPSTREAMSPEED(X,Y,Z,U,V,W,VERTICES) は、ベクトルデータ U, V, W の
% スピードを基に、ストリームラインの頂点を内挿します。配列 X, Y, Z は、
% U, V, W に対する座標系を定義し、(関数 MESHGRID で作成した)単調で、
% 3次元格子でなければなりません。   
% 
% INTERPSTREAMSPEED(U,V,W,VERTICES) は、つぎのステートメントを仮定して
% います。
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(U) です。
% 
% INTERPSTREAMSPEED(X,Y,Z,SPEED,VERTICES) は、ベクトル場のスピードに
% 3次元配列 SPEED を使います。
% 
% INTERPSTREAMSPEED(SPEED,VERTICES) は、つぎのステートメントを仮定し
% ています。
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(SPEED) です。
% 
% INTERPSTREAMSPEED(X,Y,U,V,VERTICES) は、ベクトルデータ U, V のスピード
% を基にストリームラインの頂点を内挿します。配列 X, Y は、U, V の座標を
% 定義し、(関数 MESHGRID で作成するような)単調で、2次元格子でなければ
% なりません。
% 
% INTERPSTREAMSPEED(U,V,VERTICES)  は、つぎのステートメントを仮定して
% います。
% 
%   [X Y] = meshgrid(1:N, 1:M) 
% 
% ここで、[M,N] = SIZE(U) です。
% 
% INTERPSTREAMSPEED(X,Y,SPEED,VERTICES) は、ベクトル場のスピードに、
% 2次元配列 SPEED を使います。
% 
% INTERPSTREAMSPEED(SPEED,VERTICES)  は、つぎのステートメントを仮定し
% ています。
% 
%   [X Y] = meshgrid(1:N, 1:M) 
% 
% ここで、[M,N] = SIZE(SPEED) です。
% 
% INTERPSTREAMSPEED(...SF) は、ベクトルデータのスピードを SF を使って
% スケーリングします。そのため、内挿された頂点の数をコントロールします。
% たとえば、SF を3とすると、頂点は1/3になります。
% 
% VERTSOUT = INTERPSTREAMSPEED(...) は、頂点の配列のセル配列を出力します。
% 
% 例題 1：
%        load wind
%        [sx sy sz] = meshgrid(80, 20:1:55, 5);
%        verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%        iverts = interpstreamspeed(x,y,z,u,v,w,verts,.2);
%        sl = streamline(iverts);
%        set(sl, 'marker', '.');
%        axis tight; view(2); daspect([1 1 1])
% 
% 例題 2：
%        z = membrane(6,30);
%        [u v] = gradient(z);
%        [verts averts] = streamslice(u,v);
%        iverts = interpstreamspeed(u,v,verts,15);
%        sl = streamline(iverts);
%        set(sl, 'marker', '.');
%        hold on; pcolor(z); shading interp
%        axis tight; view(2); daspect([1 1 1])
% 
% 参考：STEAMPARTICLES, STREAMSLICE, STREAMLINE, STREAM3,
%       STREAM2. 


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:05:17 $
