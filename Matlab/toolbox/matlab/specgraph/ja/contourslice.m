% CONTOURSLICE   スライス平面でのコンターライン
% 
% CONTOURSLICE(X,Y,Z,V,Sx,Sy,Sz) は、ベクトル Sx,Sy,Sz 内の点で、x,y,z
% 平面の軸にコンターラインを描画します。配列 X,Y,Z は、V に対する座標を
% 定義し、(MESHGRID で出力されるように)単調で3次元格子形でなければなり
% ません。各々の等高線でのカラーは、V により決定されます。V は、M*N*P 
% の3次元配列でなければなりません。
% 
% CONTOURSLICE(X,Y,Z,V,XI,YI,ZI) は、配列 XI,YI,ZI で定義されたサーフェス
% に沿って、体積 V を通るコンターラインを描画します。
%
% CONTOURSLICE(V,Sx,Sy,Sz) または CONTOURSLICE(V,XI,YI,ZI) は、
% [M,N,P] = SIZE(V) のとき、[X Y Z] = meshgrid(1:N、1:M、1:P) と仮定します。
% 
% CONTOURSLICE(...、N) は、(自動の値を無視して)平面毎に N 本のコンター
% ラインを描画します。
% 
% CONTOURSLICE(...、CVALS) は、ベクトル CVALS で指定した値で、平面毎に
% LENGTH(CVALS) のコンターラインを描画します。
% 
% CONTOURSLICE(...、[cv cv]) は、レベル cv で、平面毎に1つのコンターライン
% を計算します。
% 
% CONTOURSLICE(...,'method') は、使用する補間法を設定します。'method' は、
% 'linear'、'cubic'、'nearest' のいずれかです。'nearest 'は、'linear' が
% デフォルトのときに、コンターラインが XI,YI,ZI で定義されたサーフェスに
% 沿って描画されるとき以外はデフォルトです(INTERP3 を参照)。
% 
% CONTOURSLICE(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = CONTOURSLICE(...) は、PATCHオブジェクトのハンドルのベクトルをHに出力
% します。
%
% 例題:
%     [x y z v] = flow;
%     h=contourslice(x,y,z,v,[1:9],[],[0], linspace(-8,2,10));
%     axis([0 10 -3 3 -3 3]); daspect([1 1 1])
%     camva(24); camproj perspective;
%     campos([-3 -15 5])
%     set(gcf, 'Color', [.3 .3 .3], 'renderer', 'zbuffer')
%     set(gca, 'Color', 'black' , 'XColor', 'white', ...
%              'YColor', 'white' , 'ZColor', 'white')
%     box on
%
% 参考：ISOSURFACE, SMOOTH3, SUBVOLUME, REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
