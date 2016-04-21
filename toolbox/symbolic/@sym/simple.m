function [r,h] = simple(s)
%SIMPLE Search for simplest form of a symbolic expression or matrix.
%   SIMPLE(S) tries several different algebraic simplifications of
%   S, displays any which shorten the length of S's representation,
%   and returns the shortest. S is a SYM. If S is a matrix, the result
%   represents the shortest representation of the entire matrix, which is 
%   not necessarily the shortest representation of each individual element.
%
%   [R,HOW] = SIMPLE(S) does not display intermediate simplifications,
%   but returns the shortest found, as well as a string describing
%   the particular simplification. R is a SYM. HOW is a string.
%
%   Examples:
%
%      S                          R                  How
%
%      cos(x)^2+sin(x)^2          1                  simplify
%      2*cos(x)^2-sin(x)^2        3*cos(x)^2-1       simplify
%      cos(x)^2-sin(x)^2          cos(2*x)           combine(trig)
%      cos(x)+(-sin(x)^2)^(1/2)   cos(x)+i*sin(x)    radsimp
%      cos(x)+i*sin(x)            exp(i*x)           convert(exp)
%      (x+1)*x*(x-1)              x^3-x              combine(trig)
%      x^3+3*x^2+3*x+1            (x+1)^3            factor
%      cos(3*acos(x))             4*x^3-3*x          expand
%
%      syms x y positive
%      log(x) + log(y)            log(x*y)           combine
%
%   See also SIMPLIFY, FACTOR, EXPAND, COLLECT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/16 22:23:06 $

% Initialize output variables and print flag.
r = s;
h = [];
p = nargout == 0;
x = findsym(s,1);

% Try the different simplifications.
[r,h] = simpler('simplify',s,r,h,p);
[r,h] = simpler('radsimp',s,r,h,p);
[r,h] = simpler('combine',s,r,h,p,'trig');
[r,h] = simpler('factor',s,r,h,p);
[r,h] = simpler('expand',s,r,h,p);
[r,h] = simpler('combine',s,r,h,p);
[r,h] = simpler('convert',s,r,h,p,'exp');
[r,h] = simpler('convert',s,r,h,p,'sincos');
[r,h] = simpler('convert',s,r,h,p,'tan');
if ~isempty(x)
   [r,h] = simpler('collect',s,r,h,p,x);
end
try
   [r,h] = simpler('mwcos2sin',s,r,h,p);
end


function [r,h] = simpler(how,s,r,h,p,x)
%SIMPLER Used by SIMPLE to shorten expressions.
%   SIMPLER(HOW,S,R,H,P,X) applies method HOW with optional parameter X
%   to expression S, prints the result if P is nonzero, compares the
%   length of the result with expression R, which was obtained with
%   method H, and returns the shortest string and corresponding method.

if isequal(how,'mwcos2sin')
   [t,err] = mwcos2sin(s);
elseif nargin < 6
   [t,err] = maple('map',how,s);
else
   [t,err] = maple('map',how,s,x);
end

if err, return, end

if nargin == 6
   how = [how '(' x ')'];
end

if p 
   loose = isequal(get(0,'FormatSpacing'),'loose');
   if loose, disp(' '), end
   disp([how ':'])
   if loose, disp(' '), end
   disp(t)
end

if length(char(t)) < length(char(r))
   r = t;
   h = how;
end


function [s,err] = mwcos2sin(s)
% MWCOS2SIN  MathWorks additional simplifications
% mwcos2sin(s) replaces cos(E)^2 by (1-sin(E)^2) and
%    cosh(E)^2 by (1+sinh(E)^2)
siz = size(s);
s = char(s);
for k = fliplr(findstr(s,'cos('))
   p = cumsum((s(k:end)=='(')-(s(k:end)==')'));
   e = k+min(find(s(k:end)==')' & p==0))-1;
   if e+2 <= length(s) && s(e+1)=='^' && s(e+2)=='2'
      s = [s(1:k-1) '(1-sin' s(k+3:e+2) ')' s(e+3:end)];
   end
end
for k = fliplr(findstr(s,'cosh('))
   p = cumsum((s(k:end)=='(')-(s(k:end)==')'));
   e = k+min(find(s(k:end)==')' & p==0))-1;
   if e+2 <= length(s) && s(e+1)=='^' && s(e+2)=='2'
      s = [s(1:k-1) '(1+sinh' s(k+4:e+2) ')' s(e+3:end)];
   end
end
s = reshape(sym(s),siz);
[s,err] = maple('map','convert',s,'sincos');
