function varargout = unitquantize(q, varargin)
%UNITQUANTIZE  Quantize except numbers within eps of +1.
%   UNITQUANTIZE(Q,...) works the same as QUANTIZE except that numbers
%   within EPS(Q) of one are made exactly equal to +1.
%
%   Example:
%     q = quantizer('fixed','floor','saturate',[4 3]);
%     x = (0.8:.1:1.2)';
%     y = unitquantize(q,x);
%     [x y]
%     eps(q)
%
%   See also QUANTIZER, QUANTIZER/EPS, QUANTIZER/QUANTIZE, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:33:43 $

varargout = varargin;
nargs = length(varargin);
oldnover = get(q,'nover');
warn = warning;
warning('off');
for k=1:nargs
  x = varargin{k};
  if ~isempty(x)
    if isnumeric(x);
      if isreal(x)
        x = realquantize(q,x);
      else
        % Complex
        re = realquantize(q,real(x));
        im = realquantize(q,imag(x));
        if any(im(:))
          x = complex(re,im);
        end
      end
    elseif iscell(x)
      % Recursively quantize the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = unitquantize(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call unitquantize with the cell
      % array syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = unitquantize(q,values); % Unitquantize the field values
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
  varargout{k} = x;
end
warning(warn)
warning(overflowmsg(q,oldnover));

function x = realquantize(q,x)
% Record the max and min before rounding
jq = q.quantizer;
jq.setmax(max(max(x(:)),jq.max));
jq.setmin(min(min(x(:)),jq.min));
e = eps(q);
% Set any value within eps of 1 to 1
x(1-e<x & x<=1+e) = 1;
% Round first
x = round(q,x);
% Set any value within eps of 1 to 1 again in case rounding brought something
% back into within eps of 1 that wasn't there before.
x(1-e<x & x<=1+e) = 1;
% Allow 1 to be counted as a min or max value, even though 1 isn't
% quantized. 
if any(x(:)==1)
  jq.setmax(max(1,jq.max));
  jq.setmin(min(1,jq.min));
  jq.setnoperations(jq.noperations+sum(x(:)==1));
end
% Quantize only values not equal to 1
x(x~=1) = quantize(q,x(x~=1));
  
