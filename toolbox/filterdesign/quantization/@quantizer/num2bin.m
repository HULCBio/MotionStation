function varargout = num2bin(q, varargin)
%NUM2BIN  Number to binary string.
%   B = NUM2BIN(Q,X) converts numeric matrix X to binary string B.  The
%   attributes of the number are specified by quantizer object Q.  If X
%   is a cell array containing numeric matrices, then B will be a cell
%   array of the same dimension containing binary strings.  The
%   fixed-point binary representation is two's complement.  The
%   floating-point binary representation is IEEE style.
%
%   [B1,B2,...] = NUM2BIN(Q,X1,X2,...) converts numeric matrices X1, X2,
%   ... to binary strings B1, B2, ....
%
%   NUM2BIN and BIN2NUM are inverses of each other, except that NUM2BIN
%   always returns a column.
%
%   For example, all of the 3-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([3 2]);
%     x = [0.75   -0.25
%          0.50   -0.50
%          0.25   -0.75
%          0      -1   ];
%     b = num2bin(q,x)
%
%   See also QUANTIZER, QUANTIZER/BIN2NUM, QUANTIZER/HEX2NUM,
%   QUANTIZER/NUM2HEX.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:35:42 $

varargout = varargin;
nargs = length(varargin);

if isa(q,'unitquantizer')
  % When converting to binary with a unitquantizer, there is a chance to get
  % a number out of range (e.g., +1).  Hence, we change to a quantizer
  % object that uses the same java quantizer as the input.  Using the same
  % java quantizer preserves the states of the quantizer.
  q = quantizer(q.quantizer);
end

for k=1:nargs
  x=varargin{k};
  
  % NUM2BIN numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x)
      % NUM2BIN numeric arrays
      x = quantize(q,x(:));
      x = numeric2bin(q,x);
    elseif iscell(x)
      % Recursively NUM2BIN the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = num2bin(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call NUM2BIN with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = num2bin(q,values); % NUM2BIN the field values
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


function y = numeric2bin(q,x)
if isreal(x)
  y = real2bin(q,x);
else
  yr = real2bin(q,real(x));
  yi = real2bin(q,imag(x));
  p = ' + ';
  i = 'i';
  tony = ones(length(x(:)),1);
  y = [yr,p(tony,1:end),yi,i(tony,1:end)];
end
y=deblank(stringreshape(y,size(x)));

function y = real2bin(q,x)
y = hex2bin(q,num2hex(q,real(x(:))));
