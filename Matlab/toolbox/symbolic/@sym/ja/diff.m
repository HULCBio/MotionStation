% DIFF   微分
% DIFF(S)は、FINDSYMで決定されるような自由変数に関して、シンボリック式S
% を微分します。
% DIFF(S,'v')、または、DIFF(S,sym('v'))は、vに関してSを微分します。
% DIFF(S,n)は、正の整数nに対して、Sをn回微分します。
% DIFF(S,'v',n)とDIFF(S,n,'v')も利用できます。
%
% 例題 ;
% 
%      x = sym('x');
%      t = sym('t');
% 
% diff(sin(x^2))は、2*cos(x^2)*xを出力します。
% diff(t^6,6)は、720を出力します。
%
% 参考   INT, JACOBIAN, FINDSYM.



%   Copyright 1993-2002 The MathWorks, Inc.
