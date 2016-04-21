function y = getcolumn(x,n,expr)
%GETCOLUMN Get a column of data
%   Y = GETCOLUMN(X,N) returns column N of X.

%   Y = GETCOLUMN(X,N,'expression') returns an expression that
%   evaluates to column N of X. If X is a variable in the base
%   workspace the GETCOLUMN returns 'X(:,N)' and otherwise it returns
%   'getcolumn(X,N)'. If N is a vector then a cell array of strings
%   vectorized over N.

%   Copyright 1984-2003 The MathWorks, Inc. 

error(nargchk(2,3,nargin,'struct'));
if nargin == 2
  y = x(:,n);
else
  % remove spaces from front and back
  x = fliplr(deblank(fliplr(deblank(x))));

  % look for variable names in the base workspace
  isIndexable = false;
  [start,stop,token] = regexp(x,'^(\w*)([\.\{\(].*)?$');
  if ~isempty(token)
    head = x(token{1}(1):token{1}(2)-1);
    if (evalin('base',['exist(''' head ''',''var'')']) == 1)
      isIndexable = true;
    end
  end

  if isIndexable
    exprHead = '';
    exprMiddle = '(:,';
  else
    exprHead = 'getcolumn(';
    exprMiddle = ',';
  end
  
  if length(n) == 1
    y = [exprHead x exprMiddle num2str(n) ')'];
  else
    y = cell(1,length(n));
    for k=1:length(n)
      y{k} = [exprHead x exprMiddle num2str(n(k)) ')'];
    end
  end
  
end

