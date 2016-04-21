function s = wnsubstr(s)
%WNSUBSTR Convert number to TEX indices.
%   S = WNSUBSTR(N)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Feb-1998.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 19:45:35 $

if ~ischar(s) , s = sprintf('%.0f',s); end
l = length(s);
p = '_'; p = p(1,ones(1,l));
s = [p;s];
s = s(:)';
