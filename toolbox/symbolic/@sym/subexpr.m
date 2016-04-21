function [Y,sigma] = subexpr(X,signame)
%SUBEXPR Rewrite in terms of common subexpressions.
%   [Y,SIGMA] = SUBEXPR(X,SIGMA) or [Y,SIGMA] = SUBEXPR(X,'SIGMA')
%   rewrites the symbolic expression X in terms of its common
%   subexpressions. These are the subexpressions that are written
%   as %1, %2, etc. by PRETTY(S).
%   
%   Example:
%      t = solve('a*x^3+b*x^2+c*x+d = 0');
%      [r,s] = subexpr(t,'s');
%
%   See also PRETTY, SIMPLE, SUBS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2004/04/16 22:23:09 $

Y = X;

% Get name of subexpression matrix
if nargin == 1
   signame = 'sigma';
else
   if ~isstr(signame)
      signame = inputname(2); 
   end;
end

% Generate Maple labels
clear maplemex
maplemex('interface(prettyprint=true);');
maplemex([char(Y) ';'],2);
maplemex('interface(prettyprint=false);');

% Form the subexpression vector, sigma(k) = (%k).
sigma = [];
n = 0;
status = 0;
while status == 0
    n = n+1;
    v = ['%' num2str(n)];
    [result,status] = maple(v);
    if isequal(status,0)
       sigma = [sigma; sym(result)];
       maple('v := ''v'';');   %deassign v in Maple workspace
       
    end;
end;
n = n-1;
sigma = sym(sigma);

% Parse the labels in reverse order to get them in terms of one another.
if n == 1
   Y = subs(Y,sigma,signame);
else
   for k = n:-1:1
      Y = subs(Y,sigma(k),[signame '(' num2str(k) ')']);
   end
end

% If necessary, assign and display sigma.
if (nargout < 2) & (~isempty(sigma))
   assignin('caller',signame,sigma);
   loose = strcmp(get(0,'formatspacing'),'loose');
   if loose, disp(' '); end
   disp([signame,' = ']);
   if loose, disp(' '); end
   disp(sigma);
   if loose, disp(' '); end
end
