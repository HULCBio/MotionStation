% COMPOSE   関数の合成
% COMPOSE(f,g)は、f(g(y))を出力します。ここで、f = f(x)とg = g(y)です。x
% はFINDSYMで定義されるようなfのシンボリック変数で、yはFINDSYMで定義され
% るようなgのシンボリック変数です。
%
% COMPOSE(f,g,z)は、f(g(z))を出力します。ここで、f = f(x)とg = g(y)です。
% xとy は、FINDSYMで定義されるようなfとgのシンボリック変数です、
%
% COMPOSE(f,g,x,z)は、f(g(z))を出力し、xをfに対する独立変数とします。つ
% まり、f = cos(x/t)ならば、COMPOSE(f,g,x,z)は、cos(g(z)/t)を出力します。
% 一方、COMPOSE(f,g,t,z)は、cos(x/g(z))を出力します。
%  
% COMPOSE(f,g,x,y,z)は、f(g(z))を出力し、xとyをそれぞれfとgに対する独立
% 変数とします。f = cos(x/t)とg = sin(y/u)に対して、COMPOSE(f,g,x,y,z)は、
% cos(sin(z/u)/t)を出力し、一方、COMPOSE(f,g,x,u,z)は、cos(sin(y/z)/t)を
% 出力します。
% 
% 例題:
% 
%  syms x y z t u;
%  f = 1/(1 + x^2); g = sin(y); h = x^t; p = exp(-y/u);
%  compose(f,g)は、1/(1+sin(y)^2)を出力します。 
%  compose(f,g,t)は、1/(1+sin(t)^2)を出力します。
%  compose(h,g,x,z)は、sin(z)^tを出力します。
%  compose(h,g,t,z)は、x^sin(z)を出力します。
%  compose(h,p,x,y,z)は、exp(-z/u)^tを出力します。 
%  compose(h,p,t,u,z)は、x^exp(-y/z)を出力します。 
%
% 参考   FINVERSE, FINDSYM, SUBS.



%   Copyright 1993-2002 The MathWorks, Inc.
