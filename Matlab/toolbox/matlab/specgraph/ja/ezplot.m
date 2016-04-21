% EZPLOT   簡単な関数プロットの使い方
% 
% EZPLOT(f) は、デフォルトの領域 -2*pi < x < 2*pi で、数式 f = f(x) を
% プロットします。
%
% EZPLOT(f、[a,b]) は、a < x < b で f = f(x) をプロットします。
%
% 陰的に定義された関数 f = f(x,y) に対して、EZPLOT(f) は、デフォルトの
% 領域 -2*pi < x < 2*pi、-2*pi < y < 2*pi で、f(x,y) = 0 をプロットします。
% EZPLOT(f、[xmin,xmax,ymin,ymax])は、xmin < x < xmax、ymin < y < ymaxで、
% f(x,y) = 0 をプロットします。
% EZPLOT(f、[a,b]) は、a < x < b、a < y < b で、f(x,y) = 0 をプロットします。
% f が変数 u,v の関数である場合は、領域の終了点 a,b は、アルファベット順に
% ソートされます。たとえば、EZPLOT('u^2 - v^2 - 1',[-3,2,-2,3]) は、
% -3 < u < 2、-2 < v < 3 で、u^2 - v^2 - 1 = 0 をプロットします。
%
% EZPLOT(x,y) は、デフォルトの領域 0 < t < 2*pi で、パラメトリックに定義
% された平面カーブ x = x(t)、y = y(t) をプロットします。
% EZPLOT(x,y、[tmin,tmax]) は、tmin < t < tmax で、x = x(t)、y = y(t)を
% プロットします。
%
% EZPLOT(f、[a,b]、FIG)、EZPLOT(f、[xmin,xmax,ymin,ymax]、FIG),
% EZPLOT(x,y、[tmin,tmax]、FIG)は、figureウィンドウ FIG で指定された
% 領域で、与えられた関数をプロットします。
%
% EZPLOT(AX,...) は、GCAまたはFIGの代わりにAXにプロットします。
%
% H = EZPLOT(...) は、プロットされたオブジェクトのハンドルをHに出力します。
%
% 例題:
%   f は、一般的な表現ですが、@ またはインライン関数を使って指定する
%   こともできます。
%     ezplot('cos(x)')
%     ezplot('cos(x)', [0, pi])
%     ezplot('1/y-log(y)+log(-1+y)+x - 1')
%     ezplot('x^2 - y^2 - 1')
%     ezplot('x^2 + y^2 - 1',[-1.25,1.25]); axis equal
%     ezplot('x^3 + y^3 - 5*x*y + 1/5',[-3,3])
%     ezplot('x^3 + 2*x^2 - 3*x + 5 - y^2')
%     ezplot('sin(t)','cos(t)')
%     ezplot('sin(3*t)*cos(t)','sin(3*t)*sin(t)',[0,pi])
%     ezplot('t*cos(t)','t*sin(t)',[0,4*pi])
%
%     f = inline('cos(x)+2*sin(x)');
%     ezplot(f)
%     ezplot(@humps)
%
% 参考：EZCONTOUR, EZCONTOURF, EZMESH, EZMESHC, EZPLOT3,
%       EZPOLAR, EZSURF, EZSURFC, PLOT.


%   Copyright 1984-2002 The MathWorks, Inc.  
