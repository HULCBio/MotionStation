function varargout = get(Hq, property)
%GET  Get QFILT properties
%   VALUE = GET(Hq, PROPERTY) gets property or state in string PROPERTY from
%   QFILT object Hq.  
%
%   STRUCTURE = GET(Hq) gets a structure containing all the properties and
%   states of QFILT object Hq.
%
%   See QFILT for a list of properties and values.
%
%   Example:
%     Hq = qfilt;
%     q = get(Hq,'CoefficientFormat')
%
%   See also QFILT, QFILT/SET.

%   Thomas A. Bryan, 25 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.18 $  $Date: 2002/04/14 15:30:04 $

allproperties = {...
      'coefficientformat',...
      'filterstructure',...
      'inputformat',...
      'numberofsections',...
      'multiplicandformat',...
      'optimizeunitygains',...
      'outputformat',...
      'productformat',...
      'quantizedcoefficients',...
      'referencecoefficients', ...
      'report',...
      'scalevalues',...
      'statespersection',...
      'sumformat'};

if nargout == 0 & nargin == 1
  disp(Hq)
  return
end

if nargin < 2
  value.referencecoefficients = Hq.referencecoefficients;
  value.filterstructure       = Hq.filterstructure;
  value.scalevalues           = Hq.scalevalues;         
  value.coefficientformat     = Hq.coefficientformat;
  value.inputformat           = Hq.inputformat;
  value.outputformat          = Hq.outputformat;
  value.multiplicandformat    = Hq.multiplicandformat;
  value.productformat         = Hq.productformat;
  value.sumformat             = Hq.sumformat;
else 
  property = lower(property);
  ind = strmatch(property,allproperties);
  if length(ind)==1
    property = allproperties{ind};
  end
  switch property
    case 'coefficientformat'
      value = Hq.coefficientformat;
    case 'filterstructure'
      value = Hq.filterstructure;
    case 'inputformat'
      value = Hq.inputformat;
    case 'numberofsections'
      value = Hq.numberofsections;
    case 'multiplicandformat'
      value = Hq.multiplicandformat;
    case 'optimizeunitygains'
      switch class(Hq.coefficientformat)
        case 'quantum.unitquantizer'
          value = 'on';
        otherwise
          value = 'off';
      end
    case 'outputformat'
      value = Hq.outputformat;
    case 'productformat'
      value = Hq.productformat;
    case 'quantizedcoefficients'
      value = Hq.quantizedcoefficients;
    case 'referencecoefficients'
      value = Hq.referencecoefficients;
    case 'report'
      value = Hq.report;
    case 'scalevalues'
      value = Hq.scalevalues;
    case 'statespersection'
      value = Hq.statespersection;
    case 'sumformat'
      value = Hq.sumformat;
    otherwise
      error([property, [' is not a property of a QFILT object.']]);
  end
end

varargout{1}=value;
