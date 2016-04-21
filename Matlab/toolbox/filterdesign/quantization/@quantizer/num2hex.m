function varargout = num2hex(q, varargin)
%NUM2HEX  Number to hexadecimal string.
%   H = NUM2HEX(Q,X) converts numeric matrix X to hexadecimal string H.
%   The attributes of the number are specified by Quantizer object Q.
%   If X is a cell array containing numeric matrices, then H will be a
%   cell array of the same dimension containing hexadecimal strings.
%   The fixed-point hexadecimal representation is two's complement.  The
%   floating-point hexadecimal representation is IEEE style.
%
%   [H1,H2,...] = NUM2HEX(Q,X1,X2,...) converts numeric matrices X1, X2, ...
%   to hexadecimal strings H1, H2, ...
%
%   NUM2HEX and HEX2NUM are inverses of each other, except that NUM2HEX
%   always returns a column.
%
%   For example, all of the 4-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([4 3]);
%     x = [0.875    0.375   -0.125   -0.625
%          0.750    0.250   -0.250   -0.750
%          0.625    0.125   -0.375   -0.875
%          0.500        0   -0.500   -1.000];
%     h = num2hex(q,x)
%
%   See also QUANTIZER, QUANTIZER/HEX2NUM, QUANTIZER/BIN2NUM,
%   QUANTIZER/NUM2BIN.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/12 23:26:13 $

varargout = varargin;
nargs = length(varargin);

if isa(q,'unitquantizer')
  % When converting to hex with a unitquantizer, there is a chance to get
  % a number out of range (e.g., +1).  Hence, we change to a quantizer
  % object that uses the same java quantizer as the input.  Using the same
  % java quantizer preserves the states of the quantizer.
  q = quantizer(q.quantizer);
end

for k=1:nargs
  x=varargin{k};
  
  % NUMERIC2HEX numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x)
      % NUMERIC2HEX numeric arrays
      x = numeric2hex(q,x(:));
    elseif iscell(x)
      % Recursively NUM2HEX the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = num2hex(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call NUM2HEX with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = num2hex(q,values); % NUM2HEX the field values
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


function y = numeric2hex(q,x);
x = quantize(q,x);
switch q.mode
  case {'fixed','ufixed'}
    y = fix2hex(q,x);
  otherwise
    y = float2hex(q,x);
end
% Remove trailing blanks
y = deblank(y);

function y = fix2hex(q,x)
if isreal(x)
  y = realfix2hex(q,x);
else
  yr = realfix2hex(q,real(x));
  yi = realfix2hex(q,imag(x));
  p = ' + ';
  i = 'i';
  tony = ones(length(x(:)),1);
  y = [yr,p(tony,1:end),yi,i(tony,1:end)];
end
y=stringreshape(y,size(x));

function y = realfix2hex(q,x)
% Works for signed or unsigned fixed because unsigned fixed will not have any
% negative numbers. 
w = wordlength(q);
f = fractionlength(q);
x = pow2(x,f); % Convert to an integer
x(x<0) = x(x<0) + pow2(w); % Two's complement for negative numbers
y = dec2hex(x,ceil(w/4)); % Convert to hex with w/4 hex digits

function y = float2hex(q,x)
if isreal(x)
  y = realfloat2hex(q,x);
else
  yr = realfloat2hex(q,real(x));
  yi = realfloat2hex(q,imag(x));
  p = ' + ';
  i = 'i';
  tony = ones(length(x(:)),1);
  y = [yr,p(tony,1:end),yi,i(tony,1:end)];
end
y=stringreshape(y,size(x));


function y = realfloat2hex(q,x)
% This is a Java method of the Quantizer class that returns a Java String[]
% array to MATLAB as a cell array of strings.  It is wrapped in
% "char", so that it is converted to a MATLAB character array.
y = char(q.quantizer.realfloat2hex(x(:)));
