% EZMESHC   メッシュとコンターの組合わせの簡単な使い方
% 
% EZMESHC(f) は、f が文字列か、または2つのシンボリック変数 'x' と 'y' 
% を使った数学表現を表わすシンボリック表現のとき、MESHC を使って f(x,y)
% のグラフをプロットします。関数 f は、デフォルトの領域 -2*pi < x < 2*pi、
% -2*pi < y < 2*piにプロットされます。計算されるグリッドは、生ずる変化
% 量に従って選択されます。
% 
% EZMESHC(f,DOMAIN) は、デフォルトDOMAIN = [-2*pi,2*pi,-2*pi,2*pi] の
% 代わりに、指定した領域に f をプロットします。DOMAIN は、4行1列ベクトル
% [xmin,xmax,ymin,ymax]、または、(a < x < b、a < y < b にプロットするた
% めの)2行1列ベクトル [a,b] です。
%
% f が変数 u と v(x と y ではなく)の関数である場合、領域の端点umin、
% umax、vmin、vmaxは、アルファベット順に並べ替えられます。そのため、
% EZMESHC('u^2 - v^3',[0,1,3,6])は、0 < u < 1、3 < v < 6 で u^2 - v^3 
% をプロットします。
%
% EZMESHC(x,y,z) は、-2*pi < s < 2*pi と -2*pi < t < 2*pi でパラメト
% リックなサーフェス x = x(s,t)、y = y(s,t)、z = z(s,t) をプロットします。
%
% EZMESHC(x,y,z,[smin,smax,tmin,tmax])、または、EZMESHC(x,y,z,[a,b]) は、
% 指定した領域を使用します。
%
% EZMESHC(...,N) は、N行N列のグリッドを使ってデフォルトの領域に f を
% プロットします。N のデフォルト値は、60です。
%
% EZMESHC(...,'circ') は、領域上に円形に f をプロットします。
%
% EZMESHC(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZMESHC(...) は、プロットされたオブジェクトのハンドルをHに出力します。
%
% 例題:
%   f は、一般的な表現ですが、@ またはインライン関数を使って指定する
%   こともできます。
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezmeshc(f,[-pi,pi])
%    ezmeshc('x*exp(-x^2 - y^2)')
%    ezmeshc('sin(u)*sin(v)')
%    ezmeshc('imag(atan(x + i*y))',[-2,2])
%    ezmeshc('y/(1 + x^2 + y^2)',[-5,5,-2*pi,2*pi])
%
%    ezmeshc('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezmeshc(h)
%    ezmeshc(@peaks)
%
% 参考： EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURF, EZSURFC, MESHC.


%   Copyright 1984-2002 The MathWorks, Inc. 
