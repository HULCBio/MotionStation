% SUBEXPR   共通する部分式による式の書き換え
% [Y, SIGMA] = SUBEXPR(X, SIGMA)、または、[Y, SIGMA] = SUBEXPR(X, 'SIG-
% MA')は、共通する部分式によりシンボリック式 X を書き換えます。これらの
% 部分式は、PRETTY(S) による表現では、%1, %2 等で表わされます。
%   
% 例題:
%      t = solve('a*x^3+b*x^2+c*x+d = 0');
%      [r,s] = subexpr(t,'s');
%
% 参考： PRETTY, SIMPLE, SUBS.



%   Copyright 1993-2002 The MathWorks, Inc.
