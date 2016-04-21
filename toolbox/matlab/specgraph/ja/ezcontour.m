% EZCONTOUR   コンターの簡単なプロット
% 
% EZCONTOUR(f) は、f が文字列か、または2変数、'x' と 'y' を使って数学
% 関数を表わすシンボリックな表現のとき、CONTOUR を使って f(x,y) の
% コンターラインをプロットします。
% 関数 f は、デフォルトの領域 -2*pi < x < 2*pi、-2*pi < y < 2*pi に
% プロットされます。
% 計算されるグリッドは、生ずる変化の総量に従って選択されます。
%
% EZCONTOUR(f,DOMAIN) は、デフォルト DOMAIN = [-2*pi,2*pi,-2*pi,2*pi] 
% の代わりに、指定した領域 DOMAIN 上に f をプロットします。DOMAIN は、
% 4行1列ベクトル [xmin,xmax,ymin,ymax]、または(a < x < b、a < y < b に
% プロットするための)2行1列ベクトル [a,b] です。
%
% f が変数 u と v(x と y ではなく)の関数である場合、領域の終了点umin、
% umax、vmin、vmax は、アルファベット順に並べ替えられます。そのため、
% EZCONTOUR('u^2-v^3',[0,1],[3,6]) は、0 < u < 1、3 < v < 6 で、
% u^2 - v^3 に対してコンターラインをプロットします。
%
% EZCONTOUR(...,N) は、N行N列のグリッドを使ってデフォルトの領域に f を
% プロットします。N のデフォルト値は、60です。
%
% EZCONTOUR(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = EZCONTOUR(...) は、コンターオブジェクトのハンドルをHに出力します。
%
% 例題:
%    f は、一般的な表現ですが、@ や、インライン関数を使って指定する
%    こともできます。
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezcontour(f,[-pi,pi])
%    ezcontour('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezcontour('x*exp(-x^2 - y^2)')
%    ezcontour('-3*z/(1 + t^2 - z^2)',[-4,4],120)
%    ezcontour('sin(u)*sin(v)',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezcontour(h)
%    ezcontour(@peaks)
%
% 参考：EZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%       EZSURFC, EZMESHC, CONTOUR.


%   Copyright 1984-2002 The MathWorks, Inc. 
