% EZMESHC メッシュとコンターの組合わせの簡単なプロット
%
% EZMESHC(f)は、fが文字列か、または、2つのシンボリック変数'x'と'y'の数学
% 表現を表わすシンボリック表現のとき、MESHCを使って、f(x,y)のグラフをプ
% ロットします。関数f は、デフォルトの領域-2*pi < x < 2*pi, -2*pi < y < 
% 2*piにプロットされます。計算されるグリッドは、生ずる変化量に従って選択
% されます。
% 
% EZMESHC(f,DOMAIN)は、デフォルトDOMAIN = [-2*pi,2*pi,-2*pi,2*pi]の代わ
% りに、指定したDOMAINにfをプロットします。DOMAINは、4行1列のベクトル[xm
% in,xmax,ymin,ymax]、または、(a < x < b, a < y < bにプロットするための)
% 2行1列のベクトル[a,b]です。
%
% fが変数uとv(xとyではなく)の関数である場合、領域の終了点umin, umax, 
% vmin, vmax は、アルファベット順に並べ替えられます。そのため、EZMESHC
% (u^2 - v^3,[0,1,3,6]) は、0 < u < 1, 3 < v < 6で u^2 - v^3をプロット
% します。
%
% EZMESHC(x,y,z)は、-2*pi < s < 2*pi and -2*pi < t < 2*piでパラメトリッ
% クなサーフェスx = x(s,t), y = y(s,t), z = z(s,t)をプロットします。
%
% EZMESHC(x,y,z,[smin,smax,tmin,tmax])、または、EZMESHC(x,y,z,[a,b])は、
% 指定した領域を使用します。
%
% EZMESHC(...,fig)は、figureウィンドウfigにデフォルトの領域でプロットし
% ます。
%
% EZMESHC(...,'circ')は、領域上に円形にfをプロットします。
%
% 例題：
% 
%    syms x y s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezmeshc(f,[-pi,pi])
%    ezmeshc(x*exp(-x^2 - y^2))
%    ezmeshc(sin(u)*sin(v))
%    ezmeshc(imag(atan(x + i*y)),[-2,2])
%    ezmeshc(y/(1 + x^2 + y^2),[-5,5,-2*pi,2*pi])
%
%    ezmeshc((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%
% 参考： EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURFC, EZMESHC, SURF.


%   Copyright 1993-2002 The MathWorks, Inc.
