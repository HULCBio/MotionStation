% TAYLOR   Taylor 級数展開
% TAYLOR(f) は、f に対して5次の Maclaurin 多項式近似を出力します。3つの
% パラメータを任意の順序で与えることができます。
% 
% TAYLOR(f, n) は、(n-1) 次の Maclaurin 多項式です。
% TAYLOR(f, a) は、点aに関する Taylor 多項式近似を求めます。
% TAYLOR(f, x) は、FINDSYM(f) の代わりに独立変数xを使います。
%
% 例題 :
% taylor(exp(-x)) は、1-x+1/2*x^2-1/6*x^3+1/24*x^4-1/120*x^5 を出力しま
% す。
% 
% taylor(log(x),6,1) は、x-1-1/2*(x-1)^2+1/3*(x-1)^3-1/4*(x-1)^4+....
% 1/5*(x-1)^5 を出力します。
% 
% taylor(sin(x),pi/2,6) は、1-1/2*(x-1/2*pi)^2+1/24*(x-1/2*pi)^4 を出力
% します。
% 
% taylor(x^t,3,t) は、1+log(x)*t+1/2*log(x)^2*t^2を出力します。
%
% 参考： FINDSYM, SYMSUM.



%   Copyright 1993-2002 The MathWorks, Inc.
