function [c,ia,ib] = setxor(a,b,flag)
%SETXOR Set exclusive-or for Java objects.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/01/24 09:22:27 $

nIn = nargin;

if nIn < 2
  error('MATLAB:setxor:TooFewInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:setxor:TooManyInputs', 'Too many input arguments.');
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
    error('MATLAB:setxor:AorBinvalidSize',...
        'A and B must be vectors or ''rows'' must be specified.');
  end
  
  c = [a([]);b([])];
  
  % Handle empty arrays.
  
  if (numelA == 0 || numelB == 0)
    % Predefine outputs to be of the correct type.
    if (numelA == 0 && numelB == 0)
      ia = []; ib = [];
      if (max(size(a)) > 0 || max(size(b)) > 0)
        c = reshape(c,0,1);
        ia = reshape(ia,0,1);
        ib = reshape(ia,0,1);
      end
    elseif (numelA == 0)
      [c, ib] = unique(b(:));
      ia = zeros(0,1);
    else
      [c, ia] = unique(a(:));
      ib = zeros(0,1);
    end
    
    % General handling.
    
  else
  
    % Make sure a and b contain unique elements.
    [a,ia] = unique(a(:));
    [b,ib] = unique(b(:));

    % Find matching entries
    e = [a;b];
    [c,ndx] = sort(e);

    % d indicates the location of matching entries
    d = find(c(1:end-1)==c(2:end));
    ndx([d;d+1]) = []; % Remove all matching entries

    c = e(ndx);
    
    if nOut > 1
      n = length(a);
      d = ndx <= n;
      ia = ia(ndx(d));        % Find indices for set A if needed.
      if nOut > 2
        d = ndx > n;
        ib = ib(ndx(d)-n);    % Find indices for set B if needed.
      end
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
    error('MATLAB:setxor:unknownFlag', 'Unknown flag.');
  end
  % Automatically pad strings with spaces
  if ischar(a) && ischar(b)
    if colsA > colsB
      b = [b repmat(' ',rowsB,colsA-colsB)];
    elseif colsA < colsB 
      a = [a repmat(' ',rowsA,colsB-colsA)];
      colsA = colsB;
    end
  elseif colsA ~= colsB
    error('MATLAB:setxor:AandBcolnumMismatch',...
        'A and B must have the same number of columns.');
  end
  
  % Handle empty arrays.
  
  if isempty(a) && isempty(b)
    % Predefine c to be of the correct type.
    c = [a([]);b([])];
    if (rowsA + rowsB == 0)
      c = reshape(c,0,colsA);
    elseif (colsA == 0)
      c = reshape(c,(rowsA > 0) + (rowsB > 0),0);   % Empty row array.
      if rowsA > 0
        ia = rowsA;
      else
        ia = [];
      end
      if rowsB > 0
        ib = rowsB;
      else
        ib = []; 
      end
    end
    
  else
    % Remove duplicates from A and B and sort.
    if nOut <= 1
      a = unique(a,flag);
      b = unique(b,flag);
      c = sortrows([a;b]);
    else
      [a,ia] = unique(a,flag);
      [b,ib] = unique(b,flag);
      [c,ndx] = sortrows([a;b]);
    end

    % Find all non-matching entries in sorted list.
    [rowsC,colsC] = size(c);
    if rowsC > 1 && colsC ~= 0
      % d indicates the location of non-matching entries
      d = c(1:rowsC-1,:)~=c(2:rowsC,:);
    else
      d = zeros(rowsC-1,0);
    end
  
    d = any(d,2);
    d(rowsC,1) = 1;     % Last row is always unique.
    d(2:rowsC) = d(1:rowsC-1) & d(2:rowsC); % Remove both if match.
    
    c = c(d,:);         % Keep only the non-matching entries
  
    if nOut > 1
      ndx = ndx(d);     % NDX: indices of non-matching entries
      n = size(a,1);
      d = ndx <= n;     % Values in a that don't match.
      ia = ia(ndx(d));
      d = ndx > n;      % Values in b that don't match.
      ib = ib(ndx(d)-n);
    end
  end
  
  % Automatically deblank strings
  if ischar(a) && ischar(b)
    c = deblank(c);
  end
end
