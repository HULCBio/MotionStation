function tf = issorted(a,flag)
%ISSORTED True for sorted vector.
%   ISSORTED(A) when A is a vector returns 1 if the elements of A are
%   in sorted order (in other words, if A and SORT(A) are identical)
%   and 0 if not.
%
%   For character arrays, ASCII order is used.
%
%   ISSORTED(A,'rows') when A is a matrix returns 1 if the rows of A 
%   are in sorted order (if A and SORTROWS(A) are identical) and 0 if not.
%
%   See also UNIQUE, ISMEMBER, INTERSECT, SETDIFF, SETXOR, UNION.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/05/01 20:41:17 $

nIn = nargin;

if nIn < 1
  error('MATLAB:issorted:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 2
  error('MATLAB:issorted:TooManyInputs', 'Too many input arguments.');
end

if nIn == 1
  flag = '';
end

isrows = strcmpi(flag,'rows');

tf = true;

if isempty(flag)
  
  numelA = length(a);
  
  if numel(a)~=numelA
    error('MATLAB:issorted:AvectorOrRowsFlag',...
          'A must be a vector or ''rows'' must be specified.');
  end
  
  % Convert to double and columns
  a = double(a(:));
  
  % FOR loop breaks if it encounters something out of order
  for i = 1:numelA-1
    if ~(a(i) <= a(i+1))
      tf = false;
      break
    end
  end
  
  % Check for NaN's; sorted if everything after breakpoint is NaN
  if ~tf && a(i) > a(i+1)
    return
  
  % Proceed with this only if NaN found in position (i+1).
  elseif isnan(a(numelA))   % Check final element for NaN
    if all(isnan(a(i+2:numelA-1)))  % Check all others for NaN
      tf = true;
    end  
  end
else
  %% 'rows' implementation
  if ~isrows
    error('MATLAB:issorted:InvalidFlag', 'Unknown flag.'); 
  end
  
  nrows = size(a,1);
  
  for c = 1:nrows-1
    diffvec = a(c+1,:) - a(c,:);
    for i = 1:length(diffvec)
      if diffvec(i) > 0
        break
      elseif diffvec(i) < 0
        tf = false;
        return
      elseif isnan(diffvec(i))
        if isnan(a(c+1,i)) && ~isnan(a(c,i))
          break
        elseif isnan(a(c,i)) && ~isnan(a(c+1,i))
          tf = false;
          return
        end
      end
    end
  end
end