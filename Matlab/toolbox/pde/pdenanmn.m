function [m,ndx] = nanmin(a,b)
%NANMIN NaN protected minimum.
%       NANMIN(...) is the same as MIN except that the NaN's are ignored.
%
%       For vectors, MIN(X) is the smallest non-nan element in X. For
%       matrices, MIN(X) is a vector containing the minimum non-nan
%       element from each column. [M,I] = MIN(...) also returns
%       the indices of the minimum values in vector I.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:31 $

if nargin<1, error('PDE:pdenanmn:nargin', 'Not enough input arguments.'); end

if nargin==1,
  if isempty(a), m =[]; i = []; return, end

  % Check for NaN's
  d = find(isnan(a));

  if isempty(d), % No NaN's, just call min.
    [m,ndx] = min(a);
  else
    if min(size(a))==1, % Vector case
      a(d) = []; % Remove NaN's
      [m,ndx] = min(a);
      if nargout>1, % Fix-up ndx vector
        pos = 1:length(a); pos(d) = [];
        ndx = pos(ndx);
      end
    else % Matrix case
      e = any(isnan(a));
      m = zeros(1,size(a,2)); ndx = m;
      % Split into two cases
      [m(~e),ndx(~e)] = min(a(:,~e));
      e = find(e);
      for i=1:length(e),
        d = isnan(a(:,e(i)));
        aa = a(:,e(i)); aa(d) = [];
        if isempty(aa),
          m(e(i)) = NaN; ndx(e(i)) = 1;
        else
          [m(e(i)),ndx(e(i))] = min(aa);
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
      error('PDE:pdenanmn:XYsizeMismatch', 'X and Y must be the same size.'); 
  end
  if nargout>1, error('PDE:pdenanmn:nargout', 'Too many output arguments.'); end
  if isempty(a), m =[]; i = []; return, end

  d = find(isnan(a));
  a(d) = b(d);
  d = find(isnan(b));
  b(d) = a(d);
  m = min(a,b);

end

