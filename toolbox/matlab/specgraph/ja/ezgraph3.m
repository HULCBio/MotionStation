% EZGRAPH3   簡単なsurfaceプロットの補助関数
% 
% EZGRAPH3(PLOTFUN,f) は、プロット関数 PLOTFUN を使って z = f(x,y) を
% プロットします。
% PLOTFUN は、(x,y,z) を入力としてもつ SURF のような任意の関数です。
% 
% EZGRAPH3(PLOTFUN,f,[xmin xmax ymin ymax]) は、指定した領域上でプロット
% します。
% EZGRAPH3(PLOTFUN,...,DOMSTYLE) で、DOMSTYLE は 'rect' または 'circ' 
% です。
% EZGRAPH3(PLOTFUN,...,Npts) は、Npts 行 Npts 列のグリッド点を使用します。
%
% EZGRAPH3(PLOTFUN,x,y,z) は、-2*pi < s < 2*pi および -2*pi < t < 2*pi 上で、
% パラメトリックなサーフェス x = x(s,t)、y = y(s,t)、z = z(s,t) をプロット
% します。
%
% EZGRAPH3(PLOTFUN,x,y,z,[smin,smax,tmin,tmax]) または
% EZGRAPH3(x,y,z,...[a,b]) は、指定した領域を使用します。
%
% EZGRAPH3(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZGRAPH3(...) は、プロットされたオブジェクトのハンドルをHに出力します。
%
% 参考：EZPLOT, EZPLOT3, EZPOLAR, EZMESH, EZMESHC, EZSURF,
%       EZSURFC, EZCONTOUR. EZCONTOURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
