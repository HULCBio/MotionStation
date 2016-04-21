function [c,ia,ib] = intersect(a,b,flag)
%INTERSECT Set intersection for Java objects.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/01/24 09:22:23 $

nIn = nargin;

if nIn < 2
  error('MATLAB:intersect:TooFewInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:intersect:TooManyInputs', 'Too many input arguments.');
end

if nIn == 2
  flag = [];
end

isrows = strcmpi(flag,'rows');

rowsA = size(a,1);
colsA = size(a,2);
rowsB = size(b,1);
colsB = size(b,2);

rowvec = ~((rowsA > 1 && colsB <= 1) || (rowsB > 1 && colsA <= 1) || isrows);

numelA = numel(a);
numelB = numel(b);
nOut = nargout;

if isempty(flag)
  
  if length(a)~=numelA || length(b)~=numelB
    error('MATLAB:intersect:AorBinvalidSize',...
        'A and B must be vectors or ''rows'' must be specified.');
  end
  
  c = [a([]);b([])];    % Predefined to determine class of output
  
  % Handle empty: no elements.
  
  if (numelA == 0 || numelB == 0)
    % Predefine index outputs to be of the correct type.
    ia = [];
    ib = [];
    % Ambiguous if no way to determine whether to return a row or column.
    ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
      ((size(b,1)==0 && size(b,2)==0) || length(b)==1);
    if ~ambiguous
      c = reshape(c,0,1);
      ia = reshape(ia,0,1);
      ib = reshape(ia,0,1);
    end
     
    % General handling.
    
  else

    % Make sure a and b contain unique elements.
    [a,ia] = unique(a(:));
    [b,ib] = unique(b(:));

    % Find matching entries
    [c,ndx] = sort([a;b]);
    d = find(c(1:end-1)==c(2:end));
    ndx = ndx([d;d+1]);
    c = c(d);
    n = length(a);
    
    if nOut > 1
      d = ndx > n;
      ia = ia(ndx(~d));
      ib = ib(ndx(d)-n);
    end
  end
  
  % If row vector, return as row vector.
  if rowvec
    c = c.';
    if nOut > 1
      ia = ia.';
      if nOut > 2
        ib = ib.';
      end 
    end
  end
  
else    % 'rows' case
  if ~isrows
    error('MATLAB:intersect:UnknownFlag', 'Unknown flag.');
  end
  
  % Automatically pad strings with spaces
  if ischar(a) && ischar(b)
    if colsA > colsB
      b = [b repmat(' ',rowsB,colsA-colsB)];
    elseif colsA < colsB 
      a = [a repmat(' ',rowsA,colsB-colsA)];
      colsA = colsB;
    end
  elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
    error('MATLAB:intersect:AandBcolnumMismatch',...
        'A and B must have the same number of columns.');
  end
  
  % Predefine the size of c, since it may return empty.
  c = zeros(0,colsB);
  ia = [];
  ib = [];
    
  % Remove duplicates from A and B.  Only return indices if needed.
  if nOut <= 1
    a = unique(a,flag);
    b = unique(b,flag);
    c = sortrows([a;b]);
  else
    [a,ia] = unique(a,flag);
    [b,ib] = unique(b,flag);
    [c,ndx] = sortrows([a;b]);
  end
  
  % Find matching entries in sorted rows.
  [rowsC,colsC] = size(c);
  if rowsC > 1 && colsC ~= 0
    % d indicates the location of matching entries
    d = c(1:rowsC-1,:) == c(2:rowsC,:);
  else
    d = zeros(rowsC-1,0);
  end
  
  d = find(all(d,2));
  
  c = c(d,:);         % Intersect is list of matching entries
    
  if nOut > 1
    n = size(a,1);
    ia = ia(ndx(d));      % IA: indices of first matches
    ib = ib(ndx(d+1)-n);  % IB: indices of second matches
  end
  
  % Automatically deblank strings
  if ischar(a) && ischar(b)
    rowsC = size(c,1);
    c = deblank(c);
    c = reshape(c,rowsC,size(c,2));
  end
end
