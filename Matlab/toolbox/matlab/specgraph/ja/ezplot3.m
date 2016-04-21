% EZPLOT3   3次元パラメトリック曲線プロットの簡単な使い方
% 
% EZPLOT3(x,y,z) は、デフォルトの領域 0 < t < 2*pi に、空間的な曲線 
% x = x(t)、y = y(t)、z = z(t) をプロットします。
%
% EZPLOT3(x,y,z,[tmin,tmax]) は、tmin < t < tmax に曲線 x = x(t)、y = y(t)、
% z = z(t) をプロットします。
%
% EZPLOT3(x,y,z,'animate') または EZPLOT(x,y,z,[tmin,tmax],'animate') は、
% 曲線のアニメーション化した軌跡を作成します。
% 
% EZPLOT3(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZPLOT3(...) は、プロットされたオブジェクトのハンドルをHに出力します。
%
% 例題
%  関数 x, y, z は、@ またはインラインオブジェクト、方程式表現を使って設定
%  することができます。M-ファイル関数とインライン関数は、ベクトル入力を受け
%  入れられるように書く必要があります。
%        fy = inline('t .* sin(t)')
%        ezplot3(@cos, fy, @sqrt)
%        ezplot3('cos(t)', 't * sin(t)', 'sqrt(t)', [0,6*pi])
%        ezplot3(@cos, fy, @sqrt, 'animate')
%
% 参考： EZPLOT, EZSURF, EZPOLAR, PLOT, PLOT3


%   Copyright 1984-2002 The MathWorks, Inc. 
