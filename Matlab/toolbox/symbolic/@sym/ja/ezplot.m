% EZPLOT 簡単な関数プロット
% EZPLOT(f)は、デフォルトの領域 -2*pi < x < 2*pi で、数式 f=f(x) をプロ
% ットします。
%
% EZPLOT(f, [a,b])は、a < x < b で f=f(x) をプロットします。
%
% 陰的に、関数 f=f(x,y)を定義します。EZPLOT(f)は、デフォルトの領域 -2*pi
% < x  < 2*pi, -2*pi < y < 2*pi で、f(x,y) = 0をプロットします。
%
% EZPLOT(f, [xmin,xmax,ymin,ymax])は、xmin < x < xmax,  ymin < y < ymax 
% で、f(x,y) = 0 をプロットします。
% 
% EZPLOT(f, [a,b])は、a < x < b, a < y < b で、f(x,y) = 0 をプロットしま
% す。fが、変数u,vの関数である場合は、領域の終了点a,bは、アルファベット
% 順にソートされます。たとえば、EZPLOT(u^2 - v^2 - 1,[-3,2,-2,3])は、-3 
% < u < 2, -2 < v < 3 で、u^2 - v^2 - 1 = 0 をプロットします。
%
% EZPLOT(x,y)は、デフォルトの領域 0 < t < 2*pi で、パラメトリックに定義
% された平面曲線 x=x(t), y=y(t) をプロットします。EZPLOT(x,y, [tmin,tm-
% ax])は、tmin < t < tmax で、x=x(t), y=y(t)をプロットします。
%
% EZPLOT(f, [a,b], FIG), EZPLOT(f, [xmin,xmax,ymin,ymax], FIG)、または、
% EZPLOT(x,y, [tmin,tmax], FIG)は、figure ウィンドウFIGで指定された領域
% で、与えられた関数をプロットします。
%
% 例題：
%     syms x y t
%     ezplot(cos(x))
%     ezplot(cos(x), [0, pi])
%     ezplot(x^2 - y^2 - 1)
%     ezplot(x^2 + y^2 - 1,[-1.25,1.25],3); axis equal
%     ezplot(1/y-log(y)+log(-1+y)+x - 1)
%     ezplot(x^3 + y^3 - 5*x*y + 1/5,[-3,3])
%     ezplot(x^3 + 2*x^2 - 3*x + 5 - y^2)
%     ezplot(sin(t),cos(t))
%     ezplot(sin(3*t)*cos(t),sin(3*t)*sin(t),[0,pi])



%   Copyright 1993-2002 The MathWorks, Inc.
