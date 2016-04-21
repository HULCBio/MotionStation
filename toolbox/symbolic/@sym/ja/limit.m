% LIMIT   シンボリック式の極限値
% LIMIT(F, x, a) は、x -> a のときのシンボリック式 F の極限値を計算しま
% す。
% LIMIT(F, a)は、独立変数として findsym(F) を使います。
% LIMIT(F) は、極限点として a = 0を使います。
% LIMIT(F, x, a, 'right')、または、LIMIT(F, x, a, 'left')は、片側極限の
% 方向を指定します。
%
% 例題 :
%     syms x a t h;
%
%     limit(sin(x)/x) は、1を出力します。
%     limit((x-2)/(x^2-4),2) は、1/4を出力します。
%     limit((1+2*t/x)^(3*x),x,inf) は、exp(6*t) を出力します。
%     limit(1/x,x,0,'right') は、inf を出力します。
%     limit(1/x,x,0,'left') は、-inf を出力します。
%     limit((sin(x+h)-sin(x))/h,h,0) は、cos(x) を出力します。
%     v = [(1 + a/x)^x, exp(-x)];
%     limit(v,x,inf,'left') は、[exp(a),  0] を出力します。



%   Copyright 1993-2002 The MathWorks, Inc.
