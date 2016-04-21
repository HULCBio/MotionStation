function [c,ia,ib] = setxor(a,b,flag)
%SETXOR Set exclusive-or.
%   SETXOR(A,B) when A and B are vectors returns the values that are
%   not in the intersection of A and B.  The result will be sorted.
%   A and B can be cell arrays of strings.
%
%   SETXOR(A,B,'rows') when A are B are matrices with the same number
%   of columns returns the rows that are not in the intersection
%   of A and B.
%
%   [C,IA,IB] = SETXOR(...) also returns index vectors IA and IB such
%   that C is a sorted combination of the elements of A(IA) and B(IB)
%   (or A(IA,:) and B(IB,:)).
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/04/16 22:08:06 $

%   Cell array implementation in @cell/setxor.m

nIn = nargin;

if nIn < 2
  error('MATLAB:SETXOR:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:SETXOR:TooManyInputs', 'Too many input arguments.');
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
    error('MATLAB:SETXOR:AandBvectorsOrRowsFlag',...
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
    
    % Sort if unsorted.  Only check this for long lists.
    
    checksortcut = 1000;
    
    if nOut <= 1
      if numelA <= checksortcut || ~(issorted(a))
        a = sort(a);
      end
      if numelB <= checksortcut || ~(issorted(b))
        b = sort(b);
      end
    else
      if numelA <= checksortcut || ~(issorted(a))
        [a,ia] = sort(a);
      else
        ia = (1:numelA)';
      end
      if numelB <= checksortcut || ~(issorted(b))
        [b,ib] = sort(b);
      else
        ib = (1:numelB)';
      end
    end
    
    % Find members of the XOR set.  Pass to ISMEMBC directly if
    % possible (real, full, no NaN) since A and B are sorted double arrays.
    if (isreal(a) && isreal(b)) && (~issparse(a) && ~issparse(b))
      if ~isnan(b(numelB))    % Check final index of B for NaN.
        tfa = ~ismembc(a,b);
      else
        tfa = ~ismember(a,b); % Call ISMEMBER if NaN detected in B.
      end
      if ~isnan(a(numelA))    % Check final index of A for NaN.
        tfb = ~ismembc(b,a);
      else
        tfb = ~ismember(b,a); % Call ISMEMBER if NaN detected in A.
      end
    else
      tfa = ~ismember(a,b);   % If wrong types, call ISMEMBER directly.
      tfb = ~ismember(b,a);
    end
    
    % a(tfa) now contains all members of A which are not in B
    % b(tfb) now contains all members of B which are not in A
    if nOut <= 1
      c = unique([a(tfa);b(tfb)]);    % Remove duplicates from XOR list.
    else
      ia = ia(tfa);
      ib = ib(tfb);
      n = size(ia,1);
      [c,ndx] = unique([a(tfa);b(tfb)]);  % NDX holds indices to generate C.
      d = ndx > n;                        % Find indices of A and of B.
      ia = ia(ndx(~d));
      ib = ib(ndx(d) - n);
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
    error('MATLAB:SETXOR:UnknownFlag', 'Unknown flag.');
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
    error('MATLAB:SETXOR:AandBColnumAgree',...
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