function varargout = set(Hq, varargin)
%SET    Set QFILT object properties.
%   SET(Hq,'Property',Value) sets the specified property to the specified
%   value of QFILT object Hq.
%
%   SET(Hq,'Property1',Value1,'Property2',Value2,...)  sets multiple property
%   values with a single statement.  
%
%   SET(Hq,a) where a is a structure whose field names are object
%   property names, sets the properties named in each field name
%   with the values contained in the structure.
%  
%   SET(Hq,pn,pv) sets the named properties specified in the cell array
%   of strings pn to the corresponding values in the cell array pv for
%   all objects specified in H.  
%  
%   Hq.Property = Value uses the dot notation to set property Property
%   to Value.
%
%   Examples:
%     Hq = qfilt;
%     set(Hq,'FilterStructure','df1t');
%     Hq.mode = 'single'
%
%   See also QFILT, QFILT/GET.

%   Thomas A. Bryan, 24 June 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.29.4.2 $  $Date: 2004/04/12 23:26:08 $

props.quantizerproperties = {'mode','roundmode','overflowmode'};
props.qfiltproperties = {'filterstructure','referencecoefficients',...
      'optimizeunitygains', 'scalevalues'}; 
props.formatproperties = {'quantizer','format','coefficientformat','inputformat',...
      'outputformat','multiplicandformat','productformat','sumformat'};
props.structures = privfilterstructures;
settableproperties = {props.quantizerproperties{:}, props.qfiltproperties{:}, ...
      props.formatproperties{:},props.structures{:}};
readonlyproperties = {'numberofsections', 'quantizedcoefficients', ...
      'report', 'statespersection'}; 
allproperties = {settableproperties{:}, readonlyproperties{:}};  
property='';

if nargin==1 & nargout==0
  disp('QuantizedCoefficients: Quantized from reference coefficients.')
  disp('ReferenceCoefficients: Cell array of coefficients.  One cell per section.')
  disp('                       {num,den} | {{num1,den1},{num2,den2},...} |')
  disp('                       {num} | {{num1},{num2},...} | ');
  disp('                       {k} | {{k1},{k2},...} | ');
  disp('                       {k,v} | {{k1,v1},{k2,v2},...} |');
  disp(['                       {k1,k2,beta} |' ...
        ' {{k11,k21,beta1},{k12,k22,beta2},...} |']);
  disp('                       {A,B,C,D} | {{A1,B1,C1,D1},{A2,B2,C2,D2},...}');
  disp('      FilterStructure: [df1 | df1t | df2 | <df2t> | fir | firt | ')
  disp('                        symmetricfir | antisymmetricfir | ')
  disp('                        latticear | latticeallpass | ')
  disp('                        latticema | latticemaxphase | latticearma |')
  disp('                        latticeca | latticecapc | statespace]')
  disp('          ScaleValues: Vector of scale values between sections.')
  disp('    CoefficientFormat: quantizer')
  disp('          InputFormat: quantizer')
  disp('         OutputFormat: quantizer')
  disp('   MultiplicandFormat: quantizer')
  disp('        ProductFormat: quantizer')
  disp('            SumFormat: quantizer')
  return
end
if nargin==1 & nargout==1
  a.filterstructure = {};
  a.referencecoefficients = {};
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
try
  lasterr('')
  loopcounter = 1;
  while loopcounter <= length(varargin)
    value = varargin{loopcounter};
    if ischar(value)
      % set(Hq, property, value)
      % set(Hq, property1, value1, ...)
      property = value;
      ind = strmatch(lower(property),allproperties);
      if length(ind)==1
        property = allproperties{ind};
      end
      switch lower(property)
        case settableproperties
          [Hq, loopcounter] = setproperty(property, Hq, loopcounter, props, ...
              varargin{:}); 
        case readonlyproperties
          warning(['Property ',property,' is a ''read-only'' property.']);
        otherwise
          if ~isempty(ind)
            msg1 = sprintf(['''',property,...
                  ''' is an ambiguous property for a QFILT object.\n']);
            msg2 = 'Possible completions:';
            msg3 = sprintf(' ''%s'',',allproperties{ind});
            msg = [msg1, msg2, msg3(1:end-1), '.'];
          else
            msg = [property,' is not a valid property for a QFILT object.'];
          end
          error(msg)
      end  % switch lower(property)
    elseif isa(value,'struct')
      % set(Hq, ..., a, ...) where a is a struct.
      % Call like the pn,pv cell
      pn=fieldnames(value);
      pv=struct2cell(value);
      c = {pn{:};pv{:}}; % Interleave parameters and values
      w = warning; warning off;
      set(Hq,c{:});    
      warning(w)
    elseif isa(value,'cell')
      % set(Hq, ..., pn,pv, ...)
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
      w = warning; warning off;
      set(Hq,c{:});
      warning(w)
    end  % if isa ...
    loopcounter = loopcounter + 1;
  end % while loopcounter <= length(varargin)
catch 
  error(qerror(lasterr))
end

% Validate the coefficients, and build default coefficients.
[msg,c] = coeffcheck(Hq);
error(msg)
% Default coefficients are returned from coeffcheck if empties are present.
Hq.referencecoefficients = c;

[Hq.numberofsections, Hq.statespersection] = ...
    privsectionstates(Hq.filterstructure,Hq.referencecoefficients);

[msg,Hq.scalevalues] = scalevaluescheck(Hq);
warning(msg);
Hq = privquantizedesign(Hq);
if nargout==0
  % set(Hq,...)
  assignin('caller',inputname(1),Hq)
else
  % F1 = set(Hq,...)
  % [F1,F2,...] = set(Hq,...)
  for k=1:nargout
    varargout{k} = Hq;
  end
end


function [Hq, loopcounter] = setproperty(property,Hq,loopcounter,props,varargin)
loopcounter = loopcounter+1;
if loopcounter > length(varargin)
  error('Property name must by followed by a property value.');
end
switch property
  case props.quantizerproperties
    Hq = setquantizers(Hq,property,varargin{loopcounter});
  case props.formatproperties
    Hq = setformats(Hq,property,varargin{loopcounter});
  case props.qfiltproperties
    Hq = setqfiltproperties(Hq,property,varargin{loopcounter},props.structures);
  case props.structures
    % set(..., 'fir',{1:10}, ...)
    Hq = setqfiltproperties(Hq,'filterstructure',property,props.structures);
    Hq = setqfiltproperties(Hq,'referencecoefficients',varargin{loopcounter},...
        props.structures);
end

function Hq = setquantizers(Hq,property,value)
if ~strcmpi(property,'overflowmode')
  % When setting all the overflowmodes at once, leave the coefficient
  % and input quantizers alone.
  Hq.coefficientformat = setquantizer(Hq.coefficientformat,property,value);
  Hq.inputformat = setquantizer(Hq.inputformat,property,value);
end
Hq.outputformat = setquantizer(Hq.outputformat,property,value);
Hq.multiplicandformat = setquantizer(Hq.multiplicandformat,property,value);
Hq.productformat = setquantizer(Hq.productformat,property,value);
Hq.sumformat = setquantizer(Hq.sumformat,property,value);

function Hq = setformats(Hq,property,value)
if isquantizer(value)
  % Allow a quantizer to be input as a value
  switch lower(property)
    case {'quantizer','format'}
      Hq.coefficientformat = value;
      Hq.inputformat = value;
      Hq.outputformat = value;
      Hq.multiplicandformat = value;
      Hq.productformat = value;
      Hq.sumformat = value;
    case 'coefficientformat'
      Hq.coefficientformat = value;
    case 'inputformat'
      Hq.inputformat = value;
    case 'outputformat'
      Hq.outputformat = value;
    case 'multiplicandformat'
      Hq.multiplicandformat = value;
    case 'productformat'
      Hq.productformat = value;
    case 'sumformat'
      Hq.sumformat = value;
  end
else
  if ~iscell(value)
    value = {value};
  end
  switch lower(property)
    case {'quantizer','format'}
      Hq.coefficientformat = setquantizer(Hq.coefficientformat,value{:});
      Hq.inputformat = setquantizer(Hq.inputformat,value{:});
      Hq.outputformat = setquantizer(Hq.outputformat,value{:});
      Hq.multiplicandformat = setquantizer(Hq.multiplicandformat,value{:});
      Hq.productformat = setquantizer(Hq.productformat,value{:});
      Hq.sumformat = setquantizer(Hq.sumformat,value{:});
    case 'coefficientformat'
      Hq.coefficientformat = setquantizer(Hq.coefficientformat,value{:});
    case 'inputformat'
      Hq.inputformat = setquantizer(Hq.inputformat,value{:});
    case 'outputformat'
      Hq.outputformat = setquantizer(Hq.outputformat,value{:});
    case 'multiplicandformat'
      Hq.multiplicandformat = setquantizer(Hq.multiplicandformat,value{:});
    case 'productformat'
      Hq.productformat = setquantizer(Hq.productformat,value{:});
    case 'sumformat'
      Hq.sumformat = setquantizer(Hq.sumformat,value{:});
  end
end

function Hq = setqfiltproperties(Hq,property,value,structures)
switch lower(property)
  case 'filterstructure'
    [value,msg] = qpropertymatch(value,structures);
    error(msg)
    Hq.filterstructure = value;
  case 'referencecoefficients'
    Hq.referencecoefficients = value;
  case 'optimizeunitygains'
    % Allow this property to be set for backwards compatibility, but we
    % cannot get it.
    [value,msg] = qpropertymatch(value,{'on','off'});
    error(msg)
    % Make the coefficient quantizer a UNITQUANTIZER if OptimizeUnityGains is ON
    % and a QUANTIZER if OptimizeUnityGains is OFF.
    s = get(Hq.coefficientformat);
    if strcmpi(value,'on')
      Hq.coefficientformat = unitquantizer(s);
    else
      Hq.coefficientformat = quantizer(s);
    end
  case 'scalevalues'
    [msg,Hq.scalevalues] = scalevaluescheck(Hq,value);
end

  