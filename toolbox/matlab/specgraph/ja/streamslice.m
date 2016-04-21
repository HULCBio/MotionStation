% STREAMSLICE は、スライス平面内でストリームラインを作成します。
% 
% STREAMSLICE(X,Y,Z,U,V,W,Sx,Sy,Sz) は、ベクトル Sx,Sy,Sz で定義される点
% と関連したx,y,z平面での軸のベクトルデータU,V,W から、それに対応する
% 間隔の(矢印で方向を示す)ストリームラインを描画します。配列 X,Y,Z は、
% U,V,W に関する座標を定義し、単調で(MESHGRID で作成した)3次元格子をして
% いなければなりません。V は、M x N x P の3次元的な配列をしています。
% また、流れはスライス平面に平行とは考えていません。たとえば、定数 z での
% ストリームラインで、ベクトル場の z 成分、W は、平面に対するストリーム
% ラインを計算する場合に無視されます。ストリームスライスは、ストリーム
% ライン、ストリームチューブ、ストリームリボンの出発点を決定するのに
% 有効なものです。通常、STREAMSLICEをコールする前に、DataAspectRatio を
% 設定することが望まれます。
%
% STREAMSLICE(U,V,W,Sx,Sy,Sz) は、つぎのステートメントを仮定しています。
% 
%       [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(V) です。
%
% STREAMSLICE(X,Y,U,V) は、ベクトルデータ U,V から(矢印で方向を示す)
% ストリームラインを描画します。配列 X,Y は、U,V に関する座標を定義し、
% 単調で(MESHGRID で作成した)2次元格子をしていなければなりません。
%
% STREAMSLICE(U,V) は、つぎのステートメントを仮定しています。
% 
%       [X Y] = meshgrid(1:N, 1:M)
% 
% ここで、[M,N] = SIZE(V) です。
%
% STREAMSLICE(..., DENSITY) は、ストリームラインの自動的に決定した間隔を
% 変更します。DENSITY は0以上でなければなりません。デフォルト値は1です。
% 大きな値は、各平面でより多くのストリームラインを作成します。たとえば、
% 2は、おおよそ倍のストリームラインを描画し、0.5 は半分の数のストリーム
% ラインを描画します。
% 
% STREAMSLICE(...,'arrows') は、矢印で方向を示します(デフォルト)。
% STREAMSLICE(...,'noarrows') は、方向を示す矢印を表示しません。
%
% STREAMSLICE(...,'method') は、使用する内挿法を設定します。'method' は、
% 'linear','cubic','nearest' を設定することができます。'linear' がデフォルト
% です(INTERP3 を参照)。
% 
% STREAMSLICE(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = STREAMSLICE(...) は、LINE オブジェクトのハンドル番号をベクトルと
% して出力します。
%
% [VERTICES ARROWVERTICES] = STREAMSLICE(...) は、ストリームラインや
% 矢印を描画するために、頂点の2つのセル配列を出力します。これらは、任意の
% ストリームラインを描画する関数(streamline)に渡すことができます。
%
% 例題 1:
%      load wind
%      daspect([1 1 1])
%      streamslice(x,y,z,u,v,w,[],[],[5]); 
%
% 例題 2:
%      load wind
%      daspect([1 1 1])
%      [verts averts] = streamslice(u,v,w,10,10,10); 
%      streamline([verts averts]);
%      spd = sqrt(u.*u + v.*v + w.*w);
%      hold on; slice(spd,10,10,10);
%      colormap(hot)
%      shading interp
%      view(30,50); axis(volumebounds(spd));
%      camlight; material([.5 1 0])
%
% 例題 3:
%      z = peaks;
%      surf(z); hold on
%      shading interp;
%      [c ch] = contour3(z,20); set(ch, 'edgecolor', 'b')
%      [u v] = gradient(z); 
%      h = streamslice(-u,-v);  %ownhill 
%      set(h, 'color', 'k')
%      for i = 1:length(h); 
%        zi = interp2(z,get(h(i), 'xdata'), get(h(i),'ydata'));
%        set(h(i),'zdata', zi);
%      end
%      view(30,50); axis tight
%
% 参考：STREAMLINE, SLICE, CONTOURSLICE.


%   Copyright 1984-2002 The MathWorks, Inc. 
