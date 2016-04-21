function varargout = quantize(q, varargin)
%QUANTIZE  Quantize numeric data.
%   Y = QUANTIZE(Q,X) uses the quantizer object Q to quantize X.  If X
%   is a cell array, then each numeric element of the cell array is
%   quantized.  If X is a structure, then each numeric field of X is
%   quantized.  Non-numeric elements or fields of X are left unchanged.
%
%   [Y1,Y2,...] = QUANTIZE(Q,X1,X2,...) is equivalent to
%   Y1=QUANTIZE(Q,X1), Y2=QUANTIZE(Q,X2), ....
%
%   Example:
%     w = warning('on');
%     q = quantizer('fixed', 'convergent', 'wrap', [3 2]);
%     x = (-2:eps(q)/4:2)';
%     y = quantize(q,x);
%     plot(x,[x,y],'.-'); axis square
%     warning(w);
%
%   See also QUANTIZER, QUANTIZER/ROUND.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2004/04/12 23:26:14 $


varargout = varargin;
nargs = length(varargin);
oldnover = q.quantizer.nover;
warn = warning;
warning('off');
for k=1:nargs
  x=varargin{k};
  
  % Quantize numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x) | islogical(x)
      % Quantize numeric arrays
      % The Java quantizer only takes vectors of type double.  Convert x into
      % a vector, and convert it back to it's original size after
      % quantization. 
      siz = size(x);
      x = double(x(:));
      % Quantize real and imaginary parts separately.
      if isreal(x)
        x = q.quantizer.quantize(x);
      else
        xi = q.quantizer.quantize(imag(x));
        x  = q.quantizer.quantize(real(x));
        if any(xi(:))
          x = complex(x,xi);
        end
      end
      x = reshape(x,siz);
    elseif iscell(x)
      % Recursively quantize the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = quantize(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call quantize with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = quantize(q,values); % Quantize the field values
        n = length({names{:}});
        c = cell(2,n);
        for j=1:n
          c{1,j} = names{j};
          c{2,j} = {values{j}};
        end
        x(i) = struct(c{:});
      end
    end
  end
  % Set the output
  varargout{k} = x;
end
warning(warn)
warning(overflowmsg(q,oldnover));

