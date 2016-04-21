function g = finverse(f,x)
%FINVERSE Functional inverse.
%   g = FINVERSE(f) returns the functional inverse of f. 
%   f is a scalar sym representing a function of exactly 
%   one symbolic variable, say 'x'. Then g is a scalar sym
%   that satisfies g(f(x)) = x.
%
%   g = FINVERSE(f,v) uses the symbolic variable v, where v is
%   a sym, as the independent variable. Then g is a scalar 
%   sym that satisfies g(f(v)) = v. Use this form when f contains 
%   more than one symbolic variable.
%
%   Examples:
%      finverse(1/tan(x)) returns atan(1/x).
%
%      f = x^2+y;
%      finverse(f,y) returns -x^2+y.
%      finverse(f) returns (-y+x)^(1/2) and a warning that the 
%         inverse is not unique.
%
%   See also COMPOSE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:22:27 $

f = sym(f);
if nargin == 2
   x = sym(x);
   x = x.s;
else
   x = findsym(f,1);
   if isempty(x), error('symbolic:sym:finverse:errmsg1','Functional inverse does not exist.'); end;
end;

g = maple('solve',[ f.s '= _tmpy'],x);

if isempty(g)
   warning('symbolic:sym:finverse:warnmsg1',['finverse(' f.s ') cannot be found.'])
   g = sym;
else
   c = find(g==',');
   if ~isempty(c)
      warning('symbolic:sym:finverse:warnmsg2',['finverse(' f.s ') is not unique.'])
      g = g(1:c-1);
   end
end

g = sym(maple('subs',['_tmpy =' x],g));
