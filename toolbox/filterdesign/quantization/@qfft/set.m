function varargout = set(F, varargin)
%SET   Set QFFT object properties.
%   SET(F,'Property',Value) sets the specified property to the specified
%   value of QFFT object F.
%
%   SET(F,'Property1',Value1,'Property2',Value2,...)  sets multiple property
%   values with a single statement.  
%
%   SET(F,a) where a is a structure whose field names are object
%   property names, sets the properties named in each field name
%   with the values contained in the structure.
%  
%   SET(F,pn,pv) sets the named properties specified in the cell array
%   of strings pn to the corresponding values in the cell array pv for
%   quantized FFT object F.
%  
%   F.Property = Value uses the dot notation to set property Property
%   to Value.
%
%   See QFFT for a list of properties and values.
%
%   Examples:
%     F = qfft;
%     set(F,'length',64);
%
%   See also QFFT, QFFT/GET.

%   Thomas A. Bryan, 24 June 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/12 23:25:52 $

% Can still set mode, roundmode, overflowmode, optimizeunitygains.  Even
% though these are not QFFT properties, they are ways of setting all the
% quantizers.
props.quantizerproperties = {'mode','roundmode','overflowmode'};
props.qfftproperties = {'radix','length','optimizeunitygains', ...
      'scalevalues'}; 
props.formatproperties = {'quantizer','format','coefficientformat','inputformat',...
      'outputformat','multiplicandformat','productformat','sumformat'};
readonlyproperties = {'numberofsections'};
settableproperties = {props.quantizerproperties{:}, props.qfftproperties{:}, ...
      props.formatproperties{:}};
allproperties = {props.quantizerproperties{:}, props.qfftproperties{:}, ...
      props.formatproperties{:}, readonlyproperties{:}};  
property='';

if nargin==1 & nargout==0
  disp('                Radix: <2> | 4'); 
  disp('               Length: Scalar integer, length of FFT.');
  disp('    CoefficientFormat: quantizer')
  disp('          InputFormat: quantizer')
  disp('         OutputFormat: quantizer')
  disp('   MultiplicandFormat: quantizer')
  disp('        ProductFormat: quantizer')
  disp('            SumFormat: quantizer')
  disp('          ScaleValues: Vector of scale values between sections.')
  return
end
if nargin==1 & nargout==1
  a.radix = {2, 4};
  a.length = {};
  a.coefficientformat = {};
  a.inputformat = {};
  a.outputformat = {};
  a.multiplicandformat = {};
  a.productformat = {};
  a.sumformat = {};
  a.scalevalues = {};
  varargout{1} = a;
  return
end
loopcounter = 1;
while loopcounter <= length(varargin)
  value = varargin{loopcounter};
  if ischar(value)
    % set(F, property, value)
    % set(F, property1, value1, ...)
    property = value;
    ind = strmatch(lower(property),allproperties);
    if length(ind)==1
      property = allproperties{ind};
    end
    switch lower(property)
      case settableproperties
        [F, loopcounter] = setproperty(property, F, loopcounter, props, ...
            varargin{:}); 
      case readonlyproperties
        warning(['Property ',property,' is a ''read-only'' property.']);
      otherwise
        if ~isempty(ind)
          msg1 = sprintf(['''',property,...
                ''' is an ambiguous property for a QFFT object.\n']);
          msg2 = 'Possible completions:';
          msg3 = sprintf(' ''%s'',',allproperties{ind});
          msg = [msg1, msg2, msg3(1:end-1), '.'];
        else
          msg = [property,' is not a valid property for a QFFT object.'];
        end
        error(msg)
    end  % switch lower(property)
  elseif isa(value,'struct')
    % set(F, ..., a, ...) where a is a struct.
    % Call like the pn,pv cell
    pn=fieldnames(value);
    pv=struct2cell(value);
    c = {pn{:};pv{:}}; % Interleave parameters and values
    w = warning; warning off
    set(F,c{:});    
    warning(w)
  elseif isa(value,'cell')
    % set(F, ..., pn,pv, ...)
    % Cells are only valid as pn,pv cells
    % Check that the next entry is a cell and that they are the same size
    pn = value; % Property name cell
    loopcounter=loopcounter+1;  
    if loopcounter>length(varargin)
      error('Invalid parameter/value pair arguments.');
    end
    pv=varargin{loopcounter}; % Property value cell
    if ~isa(pv,'cell') | length({pn{:}})~=length({pv{:}})
      error('Invalid parameter/value pair arguments.');
    end
    c = {pn{:};pv{:}}; % Interleave parameters and values
    w = warning; warning off
    set(F,c{:});
    warning(w)
  end  % if isa ...
  loopcounter = loopcounter + 1;
end % while loopcounter <= length(varargin)

[msg,F.scalevalues] = scalevaluescheck(F);
warning(msg);

if nargout==0
  % set(F,...)
  assignin('caller',inputname(1),F)
else
  % F1 = set(F,...)
  % [F1,F2,...] = set(F,...)
  for k=1:nargout
    varargout{k} = F;
  end
end

function [F, loopcounter] = setproperty(property, F, loopcounter, props, ...
    varargin) 
loopcounter = loopcounter+1;
if loopcounter > length(varargin)
  error('Property name must by followed by a property value.');
  return
end
switch property
  case props.quantizerproperties
    F = setquantizers(F,property,varargin{loopcounter});
  case props.formatproperties
    F = setformats(F,property,varargin{loopcounter});
  case props.qfftproperties
    F = setqfftproperties(F,property,varargin{loopcounter});
end

function F = setquantizers(F,property,value)
if ~strcmpi(property,'overflowmode')
  % When setting all the overflowmodes at once, leave the coefficient
  % and input quantizers alone.
  F.coefficientformat = setquantizer(F.coefficientformat,property,value);
  F.inputformat = setquantizer(F.inputformat,property,value);
end
F.multiplicandformat = setquantizer(F.multiplicandformat,property,value);
F.outputformat = setquantizer(F.outputformat,property,value);
F.productformat = setquantizer(F.productformat,property,value);
F.sumformat = setquantizer(F.sumformat,property,value);

function F = setformats(F,property,value)
if isquantizer(value)
  % Allow a quantizer to be input as a value
  switch lower(property)
    case {'quantizer','format'}
      F.coefficientformat = value;
      F.inputformat = value;
      F.outputformat = value;
      F.multiplicandformat = value;
      F.productformat = value;
      F.sumformat = value;
    case 'coefficientformat'
      F.coefficientformat = value;
    case 'inputformat'
      F.inputformat = value;
    case 'outputformat'
      F.outputformat = value;
    case 'multiplicandformat'
      F.multiplicandformat = value;
    case 'productformat'
      F.productformat = value;
    case 'sumformat'
      F.sumformat = value;
  end
else
  if ~iscell(value)
    value = {value};
  end
  switch lower(property)
    case {'quantizer','format'}
      F.coefficientformat = setquantizer(F.coefficientformat,value{:});
      F.inputformat = setquantizer(F.inputformat,value{:});
      F.outputformat = setquantizer(F.outputformat,value{:});
      F.multiplicandformat = setquantizer(F.multiplicandformat,value{:});
      F.productformat = setquantizer(F.productformat,value{:});
      F.sumformat = setquantizer(F.sumformat,value{:});
    case 'coefficientformat'
      F.coefficientformat = setquantizer(F.coefficientformat,value{:});
    case 'inputformat'
      F.inputformat = setquantizer(F.inputformat,value{:});
    case 'outputformat'
      F.outputformat = setquantizer(F.outputformat,value{:});
    case 'multiplicandformat'
      F.multiplicandformat = setquantizer(F.multiplicandformat,value{:});
    case 'productformat'
      F.productformat = setquantizer(F.productformat,value{:});
    case 'sumformat'
      F.sumformat = setquantizer(F.sumformat,value{:});
  end
end

function F = setqfftproperties(F,property,value)
switch lower(property)
  case 'radix'
    valuecheck('Radix',value,{2, 4})
    F.radix = value;
  case 'length'
    warning(lengthcheck(F,value));
    F.length = value;
  case 'optimizeunitygains'
    valuecheck('OptimizeUnityGains',value,{'on','off'});
    % Make the coefficient quantizer a UNITQUANTIZER if OptimizeUnityGains is ON
    % and a QUANTIZER if OptimizeUnityGains is OFF.
    s = get(F.coefficientformat);
    if strcmpi(value,'on')
      F.coefficientformat = unitquantizer(s);
    else
      F.coefficientformat = quantizer(s);
    end
  case 'scalevalues'
    [msg,F.scalevalues] = scalevaluescheck(F,value);
end

function  valuecheck(property,value,validvalues);
switch value
  case validvalues
  otherwise 
    if isnumeric(value)
      value = num2str(value);
    end
    error([value,' is an invalid value for QFFT property ',property,'.']);
end

  
