function value = get(F, property)
%GET  Get QFFT properties.
%   VALUE = GET(F, PROPERTY) gets property or state in string PROPERTY from
%   QFFT object F.  
%
%   STRUCTURE = GET(F) gets a structure containing all the properties and
%   states of QFFT object F.
%
%   See QFFT for a list of properties and values.
%
%   Example:
%     F = qfft('quantizer','single','length',64);
%     L = get(F,'length')
%
%   See also QFFT, QFFT/SET.

%   Thomas A. Bryan, 25 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/14 15:25:49 $

props.qfftproperties = {'radix','length','optimizeunitygains', ...
      'scalevalues'};
props.formatproperties = {'coefficientformat','inputformat','outputformat',...
      'multiplicandformat','productformat','sumformat'};
readonlyproperties = {'numberofsections'};
settableproperties = {props.qfftproperties{:}, ...
      props.formatproperties{:}};
allproperties = {props.qfftproperties{:}, ...
      props.formatproperties{:}, readonlyproperties{:}};  

if nargout == 0 & nargin == 1
  display(F)
  return
end

% Calculated properties
numberofsections = log2(F.length)/log2(F.radix);

% All other properties are accessible from the structure

if nargin < 2
  value.radix              = F.radix;
  value.length             = F.length;
  value.coefficientformat  = F.coefficientformat;
  value.inputformat        = F.inputformat;
  value.outputformat       = F.outputformat;
  value.multiplicandformat = F.multiplicandformat;
  value.productformat      = F.productformat;
  value.sumformat          = F.sumformat;
  value.scalevalues        = F.scalevalues;         
else 
  property = lower(property);
  ind = strmatch(property,allproperties);
  if length(ind)==1
    property = allproperties{ind};
  end
  switch property
    case 'radix'
      value = F.radix;
    case 'length'
      value = F.length;
    case 'coefficientformat'
      value = F.coefficientformat;
    case 'inputformat'
      value = F.inputformat;
    case 'outputformat'
      value = F.outputformat;
    case 'multiplicandformat'
      value = F.multiplicandformat;
    case 'productformat'
      value = F.productformat;
    case 'sumformat'
      value = F.sumformat;
    case 'numberofsections'
      value = numberofsections;
    case 'scalevalues'
      value = F.scalevalues;
    case 'optimizeunitygains'
      switch class(F.coefficientformat)
        case 'quantum.unitquantizer'
          value = 'on';
        otherwise
          value = 'off';
      end
    otherwise
      error([property, [' is not a property of a QFFT object.']]);
  end
end

  
