function [c,ia,ib] = union(a,b,flag)
%UNION  Set union.
%   UNION(A,B) when A and B are vectors returns the combined values
%   from A and B but with no repetitions.  The result will be sorted.
%   A and B can be cell arrays of strings.
%
%   UNION(A,B,'rows') when A are B are matrices with the same number of
%   columns returns the combined rows from A and B with no repetitions.
%
%   [C,IA,IB] = UNION(...) also returns index vectors IA and IB such
%   that C is a sorted combination of the elements A(IA) and B(IB) 
%   (or A(IA,:) and B(IB,:)).
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $  $Date: 2004/04/16 22:08:10 $

%   Cell array implementation in @cell/union.m

nIn = nargin;

if nIn < 2
  error('MATLAB:UNION:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:UNION:TooManyInputs', 'Too many input arguments.');
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
    error('MATLAB:UNION:AandBvectorsOrRowsFlag',...
          'A and B must be vectors or ''rows'' must be specified.');
  end
  
  % Handle empty: no elements.
  
  if (numelA == 0 || numelB == 0)
    
    % Predefine outputs to be of the correct type.
    c = [a([]);b([])];
    
    if (numelA == 0 && numelB == 0)
      ia = []; ib = [];
      if (max(size(a)) > 0 || max(size(b)) > 0)
        c = reshape(c,0,1);
      end
    elseif (numelB == 0)
      % Call UNIQUE on one list if the other is empty.
      [c, ia] = unique(a(:));
      ib = zeros(0,1);
    else
      [c, ib] = unique(b(:));
      ia = zeros(0,1);
    end
    
    % General handling.
    
  else        
    % Convert to columns.
    a = a(:);
    b = b(:);
    
    if nOut <= 1
      % Call UNIQUE to do all the work.
      c = unique([a;b]);
    else
      [c,ndx] = unique([a;b]);
      % Indices determine whether an element was in A or in B.
      d = ndx > numelA;
      ia = ndx(~d);
      ib = ndx(d)-numelA;
    end
  end
  
  % If row vector, return as row vector.
  if rowvec
    c = c.';
    if nOut > 1
        ia = ia.';
        ib = ib.';
    end
  end
  
else    % 'rows' case
  if ~isrows
    error('MATLAB:UNION:UnknownFlag', 'Unknown flag.');
  end
  % Automatically pad strings with spaces
  if ischar(a) && ischar(b)
    if colsA > colsB
      b = [b repmat(' ',rowsB,colsA-colsB)];
    elseif colsA < colsB 
      a = [a repmat(' ',rowsA,colsB-colsA)];
    end
  elseif colsA ~= colsB
    error('MATLAB:UNION:AandBColnumAgree',...
          'A and B must have the same number of columns.');
  end
  
  if nOut <= 1
    % Call UNIQUE to do all the work.
    c = unique([a;b],flag);
  else
    [c,ndx] = unique([a;b],flag);
    % Indices determine whether an element was in A or in B.
    d = ndx > rowsA;
    ia = ndx(~d);
    ib = ndx(d) - rowsA;
  end
end