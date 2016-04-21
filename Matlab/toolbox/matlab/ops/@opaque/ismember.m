function [tf,loc] = ismember(a,s,flag)
%ISMEMBER True for set member for Java objects.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2004/01/24 09:22:24 $

nIn = nargin;

if nIn < 2
  error('MATLAB:ismember:TooFewInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:ismember:TooManyInputs', 'Too many input arguments.');
end

if nIn == 2
  flag = [];
end

numelA = numel(a);
numelS = numel(s);
nOut = nargout;

if isempty(flag)
  
  % Handle empty arrays and scalars.
  
  if numelA == 0 || numelS <= 1
    if (numelA == 0 || numelS == 0)
      tf = false(size(a));
      loc = zeros(size(a));
      return
      
      % Scalar A handled below.
      % Scalar S: find which elements of A are equal to S.
    elseif numelS == 1
      tf = (a == s);
      if nOut > 1
        % Use DOUBLE to convert logical "1" index to double "1" index.
        loc = double(tf);
      end
      return
    end
  else  
    % General handling.
    % Use FIND method for very small sizes of the input vector to avoid SORT.
    scalarcut = 5;  
    if numelA <= scalarcut
      tf = false(size(a));
      loc = zeros(size(a));
      if nOut <= 1
        for i=1:numelA
          tf(i) = any(a(i)==s);   % ANY returns logical.
        end
      else
        for i=1:numelA
          found = find(a(i)==s);  % FIND returns indices for LOC.
          if ~isempty(found)
            tf(i) = 1;
            loc(i) = found(end);
          end
        end
      end
    else
     
      % Duplicates within the sets are eliminated
      [au,am,an] = unique(a(:));
      if nOut <= 1
        su = unique(s(:));
      else
        [su,sm] = unique(s(:));
      end
      
      % Sort the unique elements of A and S, duplicate entries are adjacent 
      [c,ndx] = sort([au;su]);
      
      % Find matching entries
      d = c(1:end-1)==c(2:end);         % d indicates matching entries in 2-D 
      d = find(d);                      % Finds the index of matching entries
      ndx1 = ndx(d);                    % NDX1 are locations of repeats in C
      
      if nOut <= 1
        tf = ismember(an,ndx1);         % Find repeats among original list
      else
        szau = size(au,1);
        [tf,loc] = ismember(an,ndx1);   % Find loc by using given indices
        newd = d(loc(tf));              % NEWD is D for non-unique A
        where = sm(ndx(newd+1)-szau);   % Index values of SU through UNIQUE
        loc(tf) = where;                % Return last occurrence of A within S
      end
    end
    tf = reshape(tf,size(a));
    if nOut > 1
      loc = reshape(loc,size(a));
    end
  end

else    % 'rows' case
  if ~strcmpi(flag,'rows')
    error('MATLAB:ismember:UnknownFlag', 'Unknown flag.'); 
  end
  
  rowsA = size(a,1);
  colsA = size(a,2);
  rowsS = size(s,1);
  colsS = size(s,2);
  
  % Automatically pad strings with spaces
  if ischar(a) && ischar(s),
    if colsA > colsS 
      s = [s repmat(' ',rowsS,colsA-colsS)];
    elseif colsA < colsS 
      a = [a repmat(' ',rowsA,colsS-colsA)];
      colsA = colsS;
    end
  elseif size(a,2)~=size(s,2) && ~isempty(a) && ~isempty(s)
    error('MATLAB:ismember:AandBcolnumMismatch',...
        'A and S must have the same number of columns.');
  end
  
  % Empty check for 'rows'.
  if rowsA == 0 || rowsS == 0
    if (isempty(a) || isempty(s))
      tf = false(rowsA,1);
      loc = zeros(rowsA,1);
      return
    end          
  end
  
  % General handling for 'rows'.
  
  tf = false(rowsA,1);
  
  % Duplicates within the sets are eliminated
  [au,am,an] = unique(a,'rows');
  if nOut <= 1
    su = unique(s,'rows');
  else
    [su,sm] = unique(s,'rows');
  end
  
  % Sort the unique elements of A and S, duplicate entries are adjacent 
  [c,ndx] = sortrows([au;su]);
  
  % Find matching entries
  d = c(1:end-1,:)==c(2:end,:);     % d indicates matching entries in 2-D
  d = find(all(d,2));               % Finds the index of matching entries
  ndx1 = ndx(d);                    % NDX1 are locations of repeats in C
  
  if nOut <= 1
    tf = ismember(an,ndx1);         % Find repeats among original list
  else
    szau = size(au,1);
    [tf,loc] = ismember(an,ndx1);   % Find loc by using given indices
    newd = d(loc(tf));              % NEWD is D for non-unique A
    where = sm(ndx(newd+1)-szau);   % Index values of SU through UNIQUE
    loc(tf) = where;                % Return last occurrence of A within S
  end
end
