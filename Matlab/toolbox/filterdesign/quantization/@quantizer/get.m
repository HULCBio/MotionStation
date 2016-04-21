function varargout = get(q, property)
%GET  Get QUANTIZER properties.
%   VALUE = GET(Q, PROPERTY) gets property or state in string PROPERTY from
%   QUANTIZER object Q.  
%
%   STRUCTURE = GET(Q) gets a structure containing all the properties of
%   QUANTIZER object Q. 
%
%   See QUANTIZER for a list of properties and values.
%
%   Example:
%     q = quantizer('float','convergent',[32 8]);
%     struct = get(q)
%     get(q, 'mode')
%
%   See also QUANTIZER, QUANTIZER/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:34:57 $

names = {'mode','roundmode','overflowmode', ...
      'format','max','min','noverflows', 'nunderflows', 'noperations', ...
      'quantizer'};  

if nargout == 0 & nargin == 1
  display(q)
  return
end

switch q.mode
  case 'double'
    fmt = [64 11];
  case 'single'
    fmt = [32 8];
  otherwise
    fmt = q.format;
end

if nargin < 2
  % value = get(q)
  value.mode = q.mode;
  value.roundmode = q.roundmode;
  value.overflowmode = q.overflowmode;
  value.format = fmt;
  value = {value};
else 
  % value = get(q, property)
  ind = strmatch(lower(property),names);
  if length(ind)==1
    property = names{ind};
  end
  switch lower(property)
    case 'mode'
      value = {q.mode};
    case 'roundmode'
      value = {q.roundmode};
    case 'overflowmode'
      value = {q.overflowmode};
    case 'format'
      % Allow output to be either 
      % fmt = get(q,'format'); 
      value = {fmt};
      % or
      % [w,f] = get(q,'format');
      % where the meaning of "f" depends on whether you are in fixed-point or
      % one of the floating-point modes.
      if nargout==2
        value = {fmt(1),fmt(2)};
      end
    case 'max'
      value = {getmax(q)};
    case 'min'
      value = {getmin(q)};
    case 'noverflows'
      value = {q.quantizer.nover};
    case 'nunderflows'
      value = {q.quantizer.nunder};
    case 'noperations'
      value = {q.quantizer.noperations};
    case 'quantizer'
      value = {q.quantizer};
    otherwise
      error([property, [' is not a property of a QUANTIZER' ...
              ' object']]);
  end
end
varargout = {value{:}};

function value=getmax(q)    
value = q.quantizer.max;
minval = q.quantizer.min;
if value < minval
  value = 'reset';
end

function value = getmin(q)
value = q.quantizer.min;
maxval = q.quantizer.max;
if value > maxval
  value = 'reset';
end
  
