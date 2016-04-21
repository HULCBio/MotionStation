% EZSURFC   surfとcontourの組合わせの簡単な使い方
% 
% EZSURFC(f) は、f が文字列か、または2つのシンボリック変数 'x' と 'y' を
% 使った数学関数を表わすシンボリックな表現のとき、SURFC を使って f(x,y) 
% のグラフをプロットします。
% 関数 f は、デフォルトの領域 -2*pi < x < 2*pi、-2*pi < y < 2*pi に
% プロットされます。
% 計算されるグリッドは、生ずる変化の総量に従って選択されます。
% 
% EZSURFC(f,DOMAIN) は、デフォル トDOMAIN = [-2*pi,2*pi,-2*pi,2*pi] の
% 代わりに、指定した領域に f をプロットします。DOMAIN は、4行1列ベクトル
% [xmin,xmax,ymin,ymax]、または(a < x < b、a < y < b にプロットするため
% の)2行1列ベクトル [a,b] です。
%
% f が変数 u と v(x と y ではなく)の関数である場合、、領域の端点umin、
% umax、vmin、vmaxは、アルファベット順に並べ替えられます。そのため、
% EZSURFC('u^2 - v^3',[0,1,3,6]) は、0 < u < 1、3 < v < 6 に u^2 - v^3 
% をプロットします。
%
% EZSURFC(x,y,z) は、-2*pi < s < 2*pi と -2*pi < t < 2*pi にパラメト
% リックなサーフェス x = x(s,t)、y = y(s,t)、z = z(s,t) をプロットします。
%
% EZSURFC(x,y,z,[smin,smax,tmin,tmax] )または EZSURFC(x,y,z,[a,b]) は、
% 指定した領域を使用します。
%
% EZSURFC(...,N) は、N行N列のグリッドを使ってデフォルトの領域に f を
% プロットします。N のデフォルト値は、60です。
%
% EZSURFC(...,'circ') は、領域上に円形に f をプロットします。
%
% EZSURFC(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZSURFC(...) は、プロットされたオブジェクトのハンドルをHに出力します。
%
% 例題:
%   f は、一般的な表現ですが、@ またはインライン関数を使って指定する
%   こともできます。
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezsurfc(f,[-pi,pi])
%    ezsurfc('x*exp(-x^2 - y^2)')
%    ezsurfc('sin(u)*sin(v)')
%    ezsurfc('imag(atan(x + i*y))',[-2,2])
%    ezsurfc('y/(1 + x^2 + y^2)',[-5,5,-2*pi,2*pi])
%
%    ezsurfc('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezsurfc(h)
%    ezsurfc(@peaks)
%
% 参考：EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%       EZSURF, EZMESHC, SURFC.


%   Copyright 1984-2002 The MathWorks, Inc. 
