% EZSURF   3次元カラーサーフェスの簡単な使い方
% 
% EZSURF(f) は、f が文字列か、または2つのシンボリック変数 'x' と 'y' 
% を使った数学関数を表わすシンボリックな表現のとき、SURF を使って 
% f(x,y) のグラフをプロットします。
% 関数 f は、デフォルトの領域 -2*pi < x < 2*pi、-2*pi < y < 2*pi に
% プロットされます。
% 計算されるグリッドは、生ずる変化の総量に従って選択されます。
% 
% EZSURF(f,DOMAIN) は、デフォルト DOMAIN = [-2*pi,2*pi,-2*pi,2*pi] の
% 代わりに、指定した領域に f をプロットします。DOMAIN は、4行1列ベクトル
% [xmin,xmax,ymin,ymax]、または(a < x < b、a < y < b にプロットするため
% の)2行1列ベクトル [a,b] です。
%
% f が変数 u と v(x と y ではなく)の関数である場合、領域の端点umin、
% umax、vmin、vmaxは、アルファベット順に並べ替えられます。そのため、
% EZSURF('u^2 - v^3',[0,1,3,6]) は、0 < u < 1、3 < v < 6 に u^2 - v^3
% をプロットします。
%
% EZSURF(x,y,z) は、-2*pi < s < 2*pi と -2*pi < t < 2*piに、パラメト
% リックなサーフェス x = x(s,t)、y = y(s,t)、z = z(s,t) をプロットします。
%
% EZSURF(x,y,z,[smin,smax,tmin,tmax]) または EZSURF(x,y,z,[a,b]) は、
% 指定した領域を使用します。
%
% EZSURF(...,N) は、N行N列のグリッドを使って、デフォルトの領域に f を
% プロットします。N のデフォルト値は、60です。
%
% EZSURF(...,'circ') は、領域に円形にfをプロットします。
%
% EZSURF(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZSURF(...) はsurfaceオブジェクトのハンドルをHに出力します。
%
% 例題:
%   f は、一般的な表現ですが、@ またはインライン関数を使って指定する
%   こともできます。
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezsurf(f,[-pi,pi])
%    ezsurf('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezsurf('x*exp(-x^2 - y^2)')
%    ezsurf('x*(y^2)/(x^2 + y^4)')
%    ezsurf('x*y','circ')
%    ezsurf('real(atan(x + i*y))')
%    ezsurf('exp(-x)*cos(t)',[-4*pi,4*pi,-2,2])
%
%    ezsurf('s*cos(t)','s*sin(t)','t')
%    ezsurf('s*cos(t)','s*sin(t)','s')
%    ezsurf('exp(-s)*cos(t)','exp(-s)*sin(t)','t',[0,8,0,4*pi])
%    ezsurf('cos(s)*cos(t)','cos(s)*sin(t)','sin(s)',[0,pi/2,0,3*pi/2])
%    ezsurf('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%    ezsurf('(1-s)*(3+cos(t))*cos(4*pi*s)', '(1-s)*(3+cos(t))*....
%    sin(4*pi*s)', '3*s + (1 - s)*sin(t)', [0,2*pi/3,0,12] )
%
%    h = inline('x*y - x');
%    ezsurf(h)
%    ezsurf(@peaks)
%
% 参考：EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%       EZSURFC, EZMESHC, SURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
