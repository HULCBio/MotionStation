% EZCONTOUR コンターの簡単なプロット
%
% EZCONTOUR(f)は、fが文字列か、または、2変数、'x'と'y'の数学関数を表わす
% シンボリックな表現のとき、CONTOURを使って、f(x,y)のコンターラインをプ
% ロットします。関数 f は、デフォルトの領域-2*pi < x < 2*pi, -2*pi < y 
% < 2*piにプロットされます。計算されるグリッドは、生ずる変化量に従って選
% 択されます。
%
% EZCONTOUR(f,DOMAIN)は、デフォルトDOMAIN = [-2*pi,2*pi,-2*pi,2*pi]の代
% わりに、指定したDOMAINにfをプロットします。DOMAINは、4行1列のベクトル 
% [xmin,xmax,ymin, ymax]、または、(a < x < b, a < y < bにプロットするた
% めの)2行1列のベクトル[a,b]です。
%
% fが変数uとv(xとyではなく)の関数の場合、領域の終了点umin, umax, vmin, 
% vmax は、アルファベット順に並べ替えられます。そのため、EZCONTOUR(u^2-
% v^3,[0,1],[3,6])は、0 < u < 1, 3 < v < 6で、u^2 - v^3に対して、コンタ
% ーラインをプロットします。
%
% EZCONTOUR(...,fig)は、figureウィンドウfigにデフォルトの領域でプロット
% します。
%
% 例題：
%    syms x y z t u v
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezcontour(f,[-pi,pi])
%    ezcontour(sin(sqrt(x^2+y^2))/sqrt(x^2+y^2),[-6*pi,6*pi])
%    ezcontour(x*exp(-x^2 - y^2))
%    ezcontour(-3*z/(1 + t^2 - z^2),[-4,4],120)
%    ezcontour(sin(u)*sin(v),[-2*pi,2*pi])
%
% 参考： EZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%        EZSURFC, EZMESHC, CONTOUR.



%   Copyright 1993-2002 The MathWorks, Inc.
