% EZSURFC サーフェスとコンターの組合わせの簡単なプロット
%
% EZSURFC(f) は、f が文字列か、または、2つのシンボリック変数 'x' と 'y' 
% の数学表現を表わすシンボリックな表現のとき、SURFC を使って、f(x,y) の
% グラフをプロットします。関数 f は、デフォルトの領域 -2*pi < x < 2*pi, 
% -2*pi < y < 2*pi にプロットされます。計算されるグリッドは、生ずる変化
% 量に従って選択されます。
% 
% EZSURFC(f, DOMAIN) は、デフォルト DOMAIN = [-2*pi, 2*pi, -2*pi, 2*pi] 
% の代わりに、指定した DOMAIN に f をプロットします。DOMAIN は、4行1列の
% ベクトル[xmin, xmax, ymin, ymax]、または、(a < x < b, a < y < bにプロ
% ットするための)2行1列のベクトル[a, b]です。
%
% f が変数 u と v (x と y ではなく)の関数である場合、領域の終了点 umin, 
% umax, vmin, vmax は、アルファベット順に並べ替えられます。そのため、EZS
% URFC(u^2, - v^3,[0,1,3,6]) は、0 < u < 1, 3 < v < 6 に u^2 - v^3 をプ
% ロットします。
%
% EZSURFC(x, y, z)は、-2*pi < s < 2*pi と -2*pi < t < 2*pi にパラメトリ
% ックなサーフェス x = x(s, t), y = y(s, t), z = z(s, t)をプロットします。
%
% EZSURFC(x, y, z, [smin, smax, tmin, tmax])、または、EZSURFC(x, y, z, 
% [a, b])は、指定した領域を使用します。
%
% EZSURFC(..., fig)は、figure ウィンドウ fig にデフォルトの領域でプロッ
% トします。
%
% EZSURFC(..., 'circ')は、領域の中心付近の円形上に f をプロットします。
%
% 例題：
%    syms x y u v s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezsurfc(f,[-pi,pi])
%    ezsurfc(x*exp(-x^2 - y^2))
%    ezsurfc(sin(u)*sin(v))
%    ezsurfc(imag(atan(x + i*y)),[-2,2])
%    ezsurfc(y/(1 + x^2 + y^2),[-5,5,-2*pi,2*pi])
%    ezsurfc((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
% 
% 参考： EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURFC, EZMESHC, SURFC.


%   Copyright 1993-2002 The MathWorks, Inc.
