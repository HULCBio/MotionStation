% EZMESH 3次元サーフェスメッシュの簡単なプロット
%
% EZMESH(f)は、fが文字列か、または、2変数'x'と'y'の数学表現を表わすシン
% ボリックな表現のとき、MESHを使って、f(x,y)のグラフをプロットします。関
% 数fは、デフォルトの領域-2*pi < x < 2*pi, -2*pi < y < 2*piにプロットさ
% れます。計算されるグリッドは、生ずる変化量に従って選択されます。
% 
% EZMESH(f,DOMAIN)は、デフォルトDOMAIN = [-2*pi,2*pi,-2*pi,2*pi]の代わり
% に、指定したDOMAINにfをプロットします。DOMAINは、4行1列のベクトル[xmin
% xmax,ymin,ymax]、または、(a < x < b, a < y < bにプロットするための)2行
% 1列のベクトル[a,b]です。
%
% fが変数uとv(xとyではなく)の関数である場合、領域の終了点umin, umax, vmi
% n, vmax は、アルファベット順に並べ替えられます。そのため、EZMESH(u^2 -
%  v^3,[0,1,3,6]) は、0 < u < 1, 3 < v < 6に、u^2 - v^3をプロットします。
%
% EZMESH(x,y,z)は、-2*pi < s < 2*pi と -2*pi < t < 2*piにパラメトリック
% なサーフェス x = x(s,t), y = y(s,t), z = z(s,t)をプロットします。
%
% EZMESH(x,y,z,[smin,smax,tmin,tmax])、または、EZMESH(x,y,z,[a,b])は、指
% 定した領域を使用します。
%
% EZMESH(...,fig)は、figureウィンドウfigにデフォルトの領域でプロットしま
% す。
%
% EZMESH(...,'circ')は、領域の中心付近で円形上にfをプロットします。
%
%
% 例題：
% 
%    syms x y s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezmesh(f,[-pi,pi])
%    ezmesh(x*exp(-x^2 - y^2))
%    ezmesh(x*y,'circ')
%    ezmesh(real(atan(x + i*y)))
%    ezmesh(exp(-x)*cos(t),[-4*pi,4*pi,-2,2])
%
%    ezmesh(s*cos(t),s*sin(t),t)
%    ezmesh(exp(-s)*cos(t),exp(-s)*sin(t),t,[0,8,0,4*pi])
%    ezmesh((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%
% 参考： EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURFC, EZMESHC, SURF.



%   Copyright 1993-2002 The MathWorks, Inc.
