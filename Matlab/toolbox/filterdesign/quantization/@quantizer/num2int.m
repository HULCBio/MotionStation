function varargout = num2int(q, varargin)
%NUM2INT  Number to signed integer.
%   Y = NUM2INT(Q,X) converts numeric matrix X to a matrix Y containing
%   integers when Q is a fixed-point quantizer.  The relationship
%   between X and Y is Y = X*2^fractionlength(Q).  The class of Y
%   is double, but the numeric values will be integers (i.e.,
%   floating-point integers, or flints).
%
%   If Q is a floating-point quantizer, then X is returned unchanged:
%   Y=X.
%
%   If X is a cell array containing numeric matrices, then Y will be a
%   cell array of the same dimension.
%
%   [Y1,Y2,...] = NUM2INT(Q,X1,X2,...) converts numeric matrices 
%   X1, X2, ... to floating-point integer matrices Y1, Y2, ....
%
%   For example, all of the 4-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([4 3]);
%     x = [0.875    0.375   -0.125   -0.625
%          0.750    0.250   -0.250   -0.750
%          0.625    0.125   -0.375   -0.875
%          0.500        0   -0.500   -1.000];
%     y = num2int(q,x)
%
%   See also QUANTIZER, QUANTIZER/HEX2NUM, QUANTIZER/NUM2HEX, 
%   QUANTIZER/BIN2NUM, QUANTIZER/NUM2BIN.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:35:33 $

varargout = varargin;
nargs = length(varargin);

switch lower(mode(q))
  case {'float','double','single'}
    msg = sprintf(['NUM2INT is undefined for floating-point ',...
          'quantizers.  \n',...
          'Output is equal to input.']);
    warning(msg)
    return  % Early return
end

if isa(q,'unitquantizer')
  % When converting to int with a unitquantizer, there is a chance to get
  % a number out of range (e.g., +1).  Hence, we change to a quantizer
  % object that uses the same java quantizer as the input.  Using the same
  % java quantizer preserves the states of the quantizer.
  q = quantizer(q.quantizer);
end

for k=1:nargs
  x=varargin{k};
  
  % NUMERIC2INT numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x)
      % NUMERIC2INT numeric arrays
      x = numeric2int(q,x);
    elseif iscell(x)
      % Recursively NUM2INT the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = num2int(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call NUM2INT with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = num2int(q,values); % NUM2INT the field values
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


function x = numeric2int(q,x);
x = quantize(q,x);
switch q.mode
  case {'fixed','ufixed'}
    x = x*2^fractionlength(q);
end

