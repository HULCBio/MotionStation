function [b,ndx,pos] = unique(a,flag)
%UNIQUE Set unique for Java objects.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/01/24 09:22:28 $

nIn = nargin;

if nIn < 1
  error('MATLAB:unique:TooFewInputs', 'Not enough input arguments.');
elseif nIn > 2
  error('MATLAB:unique:TooManyInputs', 'Too many input arguments.');
end

if nIn == 1
  flag = [];
end

rows = size(a,1);
cols = size(a,2);

rowvec = (rows == 1) && (cols > 1); 

numelA = numel(a);
nOut = nargout;

if isempty(flag)
  
  % Handle empty: no elements.
  
  if (numelA == 0)
    % Predefine b to be of the correct type.
    b = a([]);
    if max(size(a)) > 0
      b = reshape(b,0,1);
      ndx = zeros(0,1);
      pos = zeros(0,1);
    else
      ndx = [];
      pos = [];
    end
    return
      
  elseif (numelA == 1)
    % Scalar A: return the existing value of A.
    b = a; ndx = 1; pos = 1;
    return
    
    % General handling.  
  else
    
    % Convert to columns
    a = a(:);
    
    % Sort if unsorted.  Only check this for long lists.

    if nOut <= 1
      b = sort(a);
    else
      [b,ndx] = sort(a);
    end

    % d indicates the location of non-matching entries.

    d = b(1:numelA-1) ~= b(2:numelA);
    d(numelA,1) = 1;    % Final element is always member of unique list.
    
    b = b(d);         % Create unique list by indexing into sorted list.
    
    if nOut == 3
      pos = cumsum([1;d]);        % Lists position, starting at 1.
      pos(numelA+1) = [];         % Remove extra element introduced by d.
      pos(ndx) = pos;             % Re-reference POS to indexing of SORT.
    end
    
    % Create indices if needed.
    if nOut > 1
      ndx = ndx(d);
    end
  end
  
  % If row vector, return as row vector.
  if rowvec
    b = b.';
    if nOut > 1
      ndx = ndx.';
      if nOut > 2
        pos = pos.';
      end 
    end
  end
  
else    % 'rows' case
  if ~strcmpi(flag,'rows')
    error('MATLAB:unique:unknownFlag', 'Unknown flag.');
  end
  
  % Handle empty: no rows.
  
  if (rows == 0)
    % Predefine b to be of the correct type.
    b = a([]);
    ndx = [];
    pos = [];
    b = reshape(b,0,cols);
    if cols > 0
      ndx = reshape(ndx,0,1);
    end
    return
    
    % Handle scalar: one row.    
    
  elseif (rows == 1)
    b = a; ndx = 1; pos = 1;
    return
  end
  
  % General handling.
  
  if nOut > 1 
    [b,ndx] = sortrows(a);
  else
    b = sortrows(a);
  end
  
  % d indicates the location of non-matching entries.
  
  d = b(1:rows-1,:)~=b(2:rows,:);
  
  % d = 1 if differences between rows.  d = 0 if the rows are equal.
  
  d = any(d,2);
  d(rows,1) = 1;      % Final row is always member of unique list.
  
  b = b(d,:);         % Create unique list by indexing into sorted list.
  
  % Create position mapping vector using CUMSUM.
  
  if nOut == 3
        pos = cumsum([1;d]);        % Lists position, starting at 1.
        pos(rows+1) = [];           % Remove extra element introduced by d.
        pos(ndx) = pos;             % Re-reference POS to indexing of SORT.
  end
  
  % Create indices if needed.
  if nOut > 1
    ndx = ndx(d);
  end
end
