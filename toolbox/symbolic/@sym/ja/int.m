% INT   積分
% INT(S) は、FINDSYM で定義されるようなシンボリック変数について、S の不
% 定積分を出力します。S は、シンボリックオブジェクト(行列またはスカラ)で
% す。S が定数ならば、積分は、'x' について計算されます。
% 
% INT(S, v) は、v について S の不定積分を出力します。v は、スカラシンボ
% リックオブジェクトです。
% INT(S, a, b) は、シンボリック変数について、a から b までの S の定積分
% を出力します。a と b は、倍精度のスカラ、または、シンボリックなスカラ
% です。
% INT(S, v, a, b) は、v について、a から b までの S の定積分を出力します。
%
% 例題 :
%     syms x x1 alpha u t;
%     A = [cos(x*t),sin(x*t);-sin(x*t),cos(x*t)];
%     int(1/(1+x^2)) は、atan(x) を出力します。
%     int(sin(alpha*u),alpha) は、-cos(alpha*u)/u を出力します。
%     int(besselj(1,x),x) は、-besselj(0,x) を出力します。
%     int(x1*log(1+x1),0,1) は、1/4を出力します。
%     int(4*x*t,x,2,sin(t)) は、2*sin(t)^2*t-8*t を出力します。
%     int([exp(t),exp(alpha*t)]) は、[exp(t), 1/alpha*exp(alpha*t)] を出
%     力します。
%     int(A,t) は、[sin(x*t)/x, -cos(x*t)/x]
%                  [cos(x*t)/x,  sin(x*t)/x] を出力します。



%   Copyright 1993-2002 The MathWorks, Inc.
