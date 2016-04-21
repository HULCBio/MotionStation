function r = limit(f,x,a,dir)
%LIMIT    Limit of an expression.
%   LIMIT(F,x,a) takes the limit of the symbolic expression F as x -> a.
%   LIMIT(F,a) uses findsym(F) as the independent variable.
%   LIMIT(F) uses a = 0 as the limit point.
%   LIMIT(F,x,a,'right') or LIMIT(F,x,a,'left') specify the direction
%   of a one-sided limit.
%
%   Examples:
%     syms x a t h;
%
%     limit(sin(x)/x)                 returns   1
%     limit((x-2)/(x^2-4),2)          returns   1/4
%     limit((1+2*t/x)^(3*x),x,inf)    returns   exp(6*t)
%     limit(1/x,x,0,'right')          returns   inf
%     limit(1/x,x,0,'left')           returns   -inf
%     limit((sin(x+h)-sin(x))/h,h,0)  returns   cos(x)
%     v = [(1 + a/x)^x, exp(-x)];
%     limit(v,x,inf,'left')           returns   [exp(a),  0]

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2004/04/16 22:22:49 $

f = sym(f);

% Default x is findsym(f,1).
% Default a is 0.

% Default direction is left to Maple; we do not specify
% a default unless one is explicitly provided by the user.
% MHELP LIMIT describes the defaults used by Maple.
% dir is empty unless 4 inputs are provided.

switch nargin
case 1, 
   a = '0';
   x = findsym(f,1);
   dir = '';
case 2, 
   a = x;
   x = findsym(f,1);
   dir = '';
case 3
   dir = '';
end

if any(size(x) > 1)
   error('symbolic:sym:limit:errmsg1','Variable must be a scalar.')
end
if any(size(a) > 1) 
   error('symbolic:sym:limit:errmsg2','Limit point must be a scalar.')
end
a = sym(a);
x = sym(x);

MapleString = [x.s '=' a.s ',' dir];
if isempty(dir); MapleString(end) = []; end
r = maple('map','limit',f,MapleString);

k = strmatch('undefined',char(r.s));
if ~isempty(k), [r(k).s] = deal('NaN'); end