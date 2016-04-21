% IFOURIER   逆フーリエ積分変換
% f = IFOURIER(F) は、デフォルトの独立変数 w をスカラシンボル F の逆フー
% リエ変換です。デフォルトの出力は、x の関数です。逆フーリエ変換は、w の
% 関数に適用され、x の関数を出力します。すなわち、F = F(w) => f = f(x) 
% です。
% 
% F = F(x) の場合、IFOURIER は、t の関数を出力します。すなわち、f = f(t)
% です。定義により、f(x) = 1/(2*pi) * int(F(w)*exp(i*w*x),w,-inf,inf) と
% 積分は、w に関して行われます。
% 
% f = IFOURIER(F, u) は、デフォルトの x の代わりに、u の関数 f を作成し
% ます。
% 
%    IFOURIER(F,u) <=> f(u) = 1/(2*pi) * int(F(w)*exp(i*w*u,w,-inf,inf)
% 
% ここで、u は、スカラシンボル(w に関する積分)です。f = IFOURIER(F, v, 
% u) は、デフォルト w の代わりに v の関数から構成される F を使います。す
% なわち、
% 
%   IFOURIER(F,v,u)<=> f(u) = 1/(2*pi) * int(F(v)*exp(i*v*u, v, -inf, 
%   inf) 
% 
% v に関する積分です。
% 
% 例題：
%  syms t u w x
%  ifourier(w*exp(-3*w)*sym('Heaviside(w)')) は、つぎの出力を行います。 
% 
%         1/2/pi/(3-i*t)^2
%
%  ifourier(1/(1 + w^2),u) は、つぎの出力を行います。
% 
%         1/2*exp(-u)*Heaviside(u)+1/2*exp(u)*Heaviside(-u)
%
%  ifourier(v/(1 + w^2),v,u) は、つぎの出力を行います。  
% 
%         i/(1+w^2)*Dirac(1,-u)
%         
%  ifourier(sym('fourier(f(x),x,w)'),w,x) は、つぎの出力を行います。 
% 
%         f(x)
%
% 参考： FOURIER, ILAPLACE, IZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
