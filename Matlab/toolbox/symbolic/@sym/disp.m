function disp(X)
%DISP   Displays a sym as text.
%   DISP(S) displays the scalar or array sym,
%   without printing the the sym name.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:22:16 $

loose = isequal(get(0,'FormatSpacing'),'loose');
if isempty(X) 
   disp('[ empty sym ]')
elseif all(size(X) == 1)
   s = X.s;
   s(s=='`') = [];
   disp(s)
else
   % Find maximum string length of the elements of a X
   p = size(X);
   d = ndims(X);
   for k = 1:prod(p)
      lengths(k) = length(X(k).s);
   end;
   len = max(lengths);

   for k = 1:prod(p(3:end))
      if d > 2
         if loose, disp(' '), end
         disp([inputname(1) '(:,:,' int2strnd(k,p(3:end)) ') = '])
         if loose, disp(' '), end
      end
      % Pad each element with the appropriate number of zeros
      for i = 1:p(1)
         str = '[';
         for j = 1:p(2)
            s = X(i,j,k).s;
            s(s=='`') = [];
            str = [str blanks(len-length(s)+1) s ','];
         end
         str(end) = ']';
         if p(2) == 1; str = str(2:end-1); end
         disp(str)
      end
   end
end
if loose, disp(' '), end

% ------------------------

function s = int2strnd(k,p)
s = '';
k = k-1;
for j = 1:length(p)
   d = mod(k,p(j));
   s = [s int2str(d+1) ','];
   k = (k - d)/p(j);
end
s(end) = [];
