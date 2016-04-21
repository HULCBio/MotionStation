% CCODE   シンボリック式のCコード表現
% CCODE(S)は、シンボリック式Sを評価するCのフラグメントを出力します。
%
% 例題：
% 
%    syms x
%    f = taylor(log(1+x));
%    ccode(f) =
%
%       t0 = x-x*x/2+x*x*x/3-pow(x,4.0)/4+pow(x,5.0)/5;
%
%    H = sym(hilb(3));
%    ccode(H) =
%
%    H[0][0] = 1.0;          H[0][1] = 1.0/2.0;      H[0][2] = 1.0/3.0;
%    H[1][0] = 1.0/2.0;      H[1][1] = 1.0/3.0;      H[1][2] = 1.0/4.0;
%    H[2][0] = 1.0/3.0;      H[2][1] = 1.0/4.0;      H[2][2] = 1.0/5.0;
%
% 参考   PRETTY, LATEX, FORTRAN.



%   Copyright 1993-2002 The MathWorks, Inc.
