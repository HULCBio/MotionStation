function [msg,x,y,xi] = xychk(varargin)
%XYCHK  Check arguments to 1-D and 2-D data routines.
%   [MSG,X,Y] = XYCHK(Y), or
%   [MSG,X,Y] = XYCHK(X,Y), or
%   [MSG,X,Y,XI] = XYCHK(X,Y,XI) checks the input aguments and returns
%   either an error message in MSG or valid X,Y (and XI) data.  MSG is
%   empty when there is no error.  X must be a vector and Y must have
%   length(x) rows (or be a vector itself).
%
%   [MSG,X,Y] = XYCHK(X,Y,'plot') allows X and Y to be matrices by
%   treating them the same as PLOT does.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.2 $  $Date: 2003/05/01 20:42:53 $

error(nargchk(1, 3, nargin));

nin = nargin; x = []; y = []; xi = [];

msg.message = '';
msg.identifier = '';
msg = msg(zeros(0,1));

if nin > 1 && ischar(varargin{end}),
  plot_flag = 1;
  nin = nin - 1;
else
  plot_flag = 0;
end

if nin==1, % xychk(y)
  if ischar(varargin{1}),
    msg = makeMsg('nonNumericInput', 'Input arguments must be numeric.');
    return
  end
  y = varargin{1};
  if ndims(y)>2, msg = makeMsg('non2DInput', 'Inputs must be 2-D.'); return, end
  if ~isreal(y), % Deal with complex data case.
    if min(size(y))>1 && plot_flag,
      msg = makeMsg('nonComplexVectorInput', 'Only complex vectors are supported.');
    end
    x = real(y); y = imag(y);
    return
  end
  if plot_flag==1 && min(size(y))==1, y = y(:); end
  if min(size(y))==1,
    x = reshape(1:length(y),size(y));
  else
    x = (1:size(y,1))';
  end
  if plot_flag==1 && min(size(y))>1, x = x(:,ones(1,size(y,2))); end

elseif nin>=2, % xychk(x,y) or xychk(x,y,xi) or xychk(x,y,flag)
  x = varargin{1};
  y = varargin{2};
  if ndims(x)>2 || ndims(y)>2 
    msg = makeMsg('non2DInput', 'Inputs must be 2-D.'); 
    return 
  end
  if nin==3, xi = varargin{3}; end
  if ~plot_flag % xychk(x,y,...)
      if min(size(x))>1, msg = makeMsg('XNotAVector', 'X must be a vector.'); return, end
      if min(size(x))==1, x = x(:); end
      if min(size(y))>1, % y is a matrix
        if length(x)~=size(y,1),
          msg = makeMsg('lengthXDoesNotMatchNumRowsY', 'The length of X must match the number of rows of Y.');
          return
        end
      else % y is a vector
        if length(x) ~= length(y),
          msg = makeMsg('XAndYLengthMismatch', 'X must be same length as Y.');
          return
        end
        % Make sure x has the same orientation as y.
        x = reshape(x,size(y));
      end
  else % xychk(x,y,'plot')
      if min(size(x))==1, x = x(:); end
      if min(size(y))==1, y = y(:); end
      % Copy x as columns.
      if size(x,2)==1, x = x(:,ones(1,size(y,2))); end
      if size(x,1) ~= size(y,1), 
        msg = makeMsg('lengthXDoesNotMatchNumRowsY', 'The length of X must match the number of rows of Y.');
        return
      end
      if ~isequal(size(x),size(y)),
        msg = makeMsg('XAndYSizeMismatch', 'X and Y must be the same size.');
        return
      end
  end
end

function msg = makeMsg(identifier, message)
msg.message = message;
msg.identifier = ['MATLAB:xychk:' identifier];
