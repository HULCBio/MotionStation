function [c,ia,ib] = intersect(a,b,flag)
%INTERSECT Set intersection.
%   INTERSECT(A,B) when A and B are vectors returns the values common
%   to both A and B. The result will be sorted.  A and B can be cell
%   arrays of strings.
%
%   INTERSECT(A,B,'rows') when A are B are matrices with the same
%   number of columns returns the rows common to both A and B.
%
%   [C,IA,IB] = INTERSECT(...) also returns index vectors IA and IB
%   such that C = A(IA) and C = B(IB) (or C = A(IA,:) and C = B(IB,:)).
%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/16 22:07:47 $

%   Cell array implementation in @cell/intersect.m

nIn = nargin;

if nIn < 2
  error('MATLAB:INTERSECT:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:INTERSECT:TooManyInputs', 'Too many input arguments.');
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
    error('MATLAB:INTERSECT:AandBvectorsOrRowflag',...
          'A and B must be vectors, or ''rows'' must be specified.');
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
    
    % Handle scalars: one element.
    
  elseif (numelA == 1)
    % Scalar A: pass to ISMEMBER to determine if A exists in B.
    [tf,pos] = ismember(a,b);
    if tf
      c = a;
      ib = pos;
      ia = 1;
    else
      ia = []; ib = [];
    end
  elseif (numelB == 1)
    % Scalar B: pass to ISMEMBER to determine if B exists in A.
    [tf,pos] = ismember(b,a);
    if tf
      c = b;
      ia = pos;
      ib = 1;
    else
      ia = []; ib = [];
    end
    
    % General handling.
    
  else
    
    % Convert to columns.
    a = a(:);
    b = b(:);
    
    % Convert to double arrays, which sort faster than other types.
    
    whichclass = class(c);    
    isdouble = strcmp(whichclass,'double');
    
    if ~isdouble    
      if ~strcmp(class(a),'double')
        a = double(a);
      end
      if ~strcmp(class(b),'double')
        b = double(b);
      end
    end
    
    % Switch to sort shorter list.
    
    if numelA < numelB
      if nOut > 1
        [a,ia] = sort(a);           % Return indices only if needed.
      else
        a = sort(a);
      end
      
      [tf,pos] = ismember(b,a);     % TF lists matches at positions POS.
      
      where = zeros(size(a));       % WHERE holds matching indices
      where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
      tfs = where > 0;              % TFS is logical of WHERE.
      
      % Create intersection list.
      c = a(tfs);                     
      
      if nOut > 1                  
        % Create index vectors if requested.
        ia = ia(tfs);
        if nOut > 2
          ib = where(tfs);
        end
      end
    else
      if nOut > 1
        [b,ib] = sort(b);           % Return indices only if needed.
      else
        b = sort(b);
      end
      
      [tf,pos] = ismember(a,b);     % TF lists matches at positions POS.
      
      where = zeros(size(b));       % WHERE holds matching indices
      where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
      tfs = where > 0;              % TFS is logical of WHERE.
      
      % Create intersection list.
      c = b(tfs);
      
      if nOut > 1                  
        % Create index vectors if requested.
        ia = where(tfs);
        if nOut > 2
          ib = ib(tfs);
        end
      end
    end  
    
    % Re-convert to correct output data type using FEVAL.
    if ~isdouble
      c = feval(whichclass,c);
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
    error('MATLAB:INTERSECT:UnknownFlag', 'Unknown flag.');
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
    error('MATLAB:INTERSECT:AandBColnumAgree',...
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