% EZMESH   3次元メッシュの簡単な使い方
% 
% EZMESH(f) は、f が文字列か、または2変数 'x' と 'y' を使った数学関数
% を表わすシンボリックな表現のとき、MESH を使って f(x,y) のグラフを
% プロットします。関数 f は、デフォルトの領域 -2*pi < x < 2*pi、
% -2*pi < y < 2*pi にプロットされます。計算されるグリッドは、生ずる変化
% の総量に従って選択されます。
% 
% EZMESH(f,DOMAIN) は、デフォルトDOMAIN = [-2*pi,2*pi,-2*pi,2*pi] の
% 代わりに、指定した領域に f をプロットします。DOMAIN は、4行1列ベクトル
% [xmin,xmax,ymin,ymax]、または(a < x < b、a < y < b にプロットするた
% めの)2行1列ベクトル [a,b] です。
%
% f が変数 u と v(x と y ではなく)の関数である場合、領域の端点 umin、
% umax、vmin、vmax は、アルファベット順に並べ替えられます。そのため、
% EZMESH('u^2 - v^3',[0,1,3,6]) は、0 < u < 1、3 < v < 6 に、u^2 - v^3
% をプロットします。
% 
% EZMESH(x,y,z) は、-2*pi < s < 2*pi and -2*pi < t < 2*pi にパラメト
% リックなサーフェス x = x(s,t)、y = y(s,t)、z = z(s,t) をプロットします。
%
% EZMESH(x,y,z,[smin,smax,tmin,tmax]) または EZMESH(x,y,z,[a,b]) は、
% 指定した領域を使用します。
%
% EZMESH(...,N) は、N行N列のグリッドを使ってデフォルトの領域に f を
% プロットします。N のデフォルト値は、60です。
%
% EZMESH(...,'circ') は、円形領域上に f をプロットします。
%
% EZMESH(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZMESH(...) は、プロットされたオブジェクトのハンドルをHに出力します。
%
% 例題:
%   f は、一般的な表現ですが、@ またはインライン関数を使って指定する
%   こともできます。
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezmesh(f,[-pi,pi])
%    ezmesh('x*exp(-x^2 - y^2)')
%    ezmesh('x*y','circ')
%    ezmesh('real(atan(x + i*y))')
%    ezmesh('exp(-x)*cos(t)',[-4*pi,4*pi,-2,2])
%
%    ezmesh('s*cos(t)','s*sin(t)','t')
%    ezmesh('exp(-s)*cos(t)','exp(-s)*sin(t)','t',[0,8,0,4*pi])
%    ezmesh('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezmesh(h)
%    ezmesh(@peaks)
%
% 参考：EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZSURF, 
%       EZSURFC, EZMESHC, MESH.



%   Copyright 1984-2002 The MathWorks, Inc. 
