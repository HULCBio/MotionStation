function [xx11, yy1] = comalog(usr_data, ord)
%COMALOG Calculate the curve fitting figure data.
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.13 $

x1 = usr_data(1, :);
y1 = usr_data(2, :);
[x1, st] = sort(x1);
y1 = y1(st);
% polynomial fitting
xx11=logspace(log10(min(x1)), log10(max(x1)));
if ~isempty(y1>0)
   ind = find(y1>0);
   if max(ind) < length(y1)
      y1(max(ind)+1) = min(y1(ind))^2/max(y1);
   else
      y1 = [y1(:); min(y1(ind))^2/max(y1)];
      x1 = [x1(:); max(x1)];
   end;
   x1 = x1(y1>0);
   y1 = y1(y1>0);
end
if length(y1) <= ord
   disp('Warning: data length is too few to fit your specified order.')
   p = polyfit(log10(x1),...
      log10(y1),...
      length(y1) - 1);
else
   p = polyfit(log10(x1), log10(y1), ord);
end;
yy1 = polyval(p, log10(xx11));
      