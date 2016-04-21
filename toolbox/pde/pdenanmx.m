function [m,ndx] = pdenanmx(a,b)
%PDENANMX NaN protected maximum.
%       PDENANMX(...) is the same as MAX except that the NaN's are ignored.
%
%       For vectors, MAX(X) is the smallest non-nan element in X. For
%       matrices, MAX(X) is a vector containing the maximum non-nan
%       element from each column. [M,I] = MAX(...) also returns
%       the indices of the maximum values in vector I.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:32 $

if nargin<1, error('PDE:pdenanmx:nargin', 'Not enough input arguments.'); end
if nargin==1,
  if isempty(a), m =[]; i = []; return, end

  % Check for NaN's
  d = find(isnan(a));

  if isempty(d), % No NaN's, just call max.
    [m,ndx] = max(a);
  else
    if min(size(a))==1, % Vector case
      a(d) = []; % Remove NaN's
      [m,ndx] = max(a);
      if nargout>1, % Fix-up ndx vector
        pos = 1:length(a); pos(d) = [];
        ndx = pos(ndx);
      end
    else % Matrix case
      e = any(isnan(a));
      m = zeros(1,size(a,2)); ndx = m;
      % Split into two cases
      [m(~e),ndx(~e)] = max(a(:,~e)); % No NaN's in column.
      e = find(e);
      for i=1:length(e), % NaN's in column
        d = isnan(a(:,e(i)));
        aa = a(:,e(i)); aa(d) = [];
        if isempty(aa),
          m(e(i)) = NaN; ndx(e(i)) = 1;
        else
          [m(e(i)),ndx(e(i))] = max(aa);
          if nargout>1, % Fix-up ndx vector
            pos = 1:size(a,1); pos(d) = [];
            ndx(e(i)) = pos(ndx(e(i)));
          end
        end
      end
    end
  end
elseif nargin==2,
  if any(size(a)~=size(b))
      error('PDE:pdenanmx:XYSizeMismatch', 'X and Y must be the same size.'); 
  end
  if nargout>1, error('PDE:pdenanmx:nargout', 'Too many output arguments.'); end
  if isempty(a), m =[]; i = []; return, end

  d = find(isnan(a));
  a(d) = b(d);
  d = find(isnan(b));
  b(d) = a(d);
  m = max(a,b);
end

