function varargout = set(q, varargin)
%SET  Set QUANTIZER object properties.
%   SET(Q,'Property1',Value1,'Property2',Value2,...)  assigns values
%   associated with named properties.
%
%   Q.Property = Value uses the dot notation to set property
%   PropertyName to Value.
%
%   SET(Q,a) where a is a structure whose field names are object
%   property names, sets the properties named in each field name with
%   the values contained in the structure.
%  
%   SET(Q,pn,pv) sets the named properties specified in the cell array
%   of strings pn to the corresponding values in the cell array pv.
%  
%   Setting any of the values clears the states of the quantizer Q.  The
%   states are Max, Min, NOverflows, NUnderflows, NOperations.
%
%   See QUANTIZER for a list of properties and values.
%
%   Examples:
%
%   Entering as property/value pairs:
%     q = quantizer;
%     set(q, 'mode','fixed', ...
%            'roundmode','ceil', ...
%            'overflowmode','wrap', ...
%            'format',[24 22]);
%     disp(q)
%     
%   Using dot notation:
%     q = quantizer;
%     q.mode = 'fixed';
%     q.roundmode = 'ceil';
%     q.overflowmode = 'wrap';
%     q.format = [24 22];
%     disp(q)
%
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/RESET.


%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.23 $  $Date: 2002/04/14 15:33:57 $

packagename = 'com.mathworks.toolbox.filterdesign.';
overflowmodes = {'saturate', 'wrap'};
roundmodes = {'ceil', 'convergent', 'fix', 'floor', 'round' };
modes = {'fixed', 'ufixed', 'float', 'double', 'single'};
properties = {'mode','roundmode','overflowmode', ...
      'format','max','min','noverflows', 'nunderflows', 'noperations', ...
      'quantizer'};  
names = {overflowmodes{:},roundmodes{:},modes{:},properties{:}};
property='';

if nargin==1 & nargout==0
  disp('          Mode: [double | float | {fixed} | single | ufixed]')
  disp('     RoundMode: [ceil | convergent | fix | {floor} | round]')
  disp('  OverflowMode: [{saturate} | wrap]')
  disp('        Format: [wordlength  fractionlength] - In ''fixed'', ''ufixed'' mode.') 
  disp('                [wordlength  exponentlength] - In ''float'' mode.')
  disp('                [16 15] = default.')
  disp('           Max: Maximum value before quantize.')
  disp('           Min: Minimum value before quantize.')
  disp('    NOverflows: Number of overflows.')
  disp('   NUnderflows: Number of underflows.')
  return
end
if nargin==1 & nargout==1
  h.Mode = {'double', 'float', 'fixed', 'single', 'ufixed'};
  h.RoundMode = {'ceil', 'convergent', 'fix', 'floor', 'round'};
  h.OverflowMode = {'saturate', 'wrap'};
  h.Format = {};
  h.Max = {};
  h.Min = {};
  h.Overflows = {};
  h.NUnderflows = {};
  varargout{1} = h;
  return
end

loopcounter = 1;
while loopcounter <= length(varargin)
  value = varargin{loopcounter};
  
  if ischar(value)
    ind = strmatch(lower(value),names);
    if length(ind)==1
      value = names{ind};
    end
    switch lower(value)
      case properties
        % set(q, property)
        % set(q, property, value)
        % set(q, property1, value1, ...)
        property=value;
        switch length(varargin)
          case 1
            % set(q, property)
            switch lower(value)
              case 'mode'
                disp('[double | float | fixed | single | ufixed]')
              case 'roundmode'
                disp('[ceil | convergent | fix | floor | round]')
              case 'overflowmode'
                disp('[saturate | wrap]')
              case 'format'
                disp('[wordlength  fractionlength] - The format for fixed, ufixed mode.')
                disp('[wordlength  exponentlength] - The format for float mode.')
              case 'max'
                disp('Maximum value before quantize.')
              case 'min'
                disp('Minimum value before quantize.')
              case 'noverflows'
                disp('Number of overflows.')
              case 'nunderflows'
                disp('Number of underflows.')
              case 'noperations'
                disp('Number quantization operations.')
            end
            return  % early out of the function
          otherwise
            % set(q, property, value)
            % set(q, property1, value1, ...)
            switch property
              % Test for read-only properties.
              case {'max','min','noverflows','nunderflows','noperations'}
                msg=sprintf([property,' is a state of a QUANTIZER' ...
                      ' object that is \nupdated during the' ...
                      ' QUANTIZER/QUANTIZE operation and reset with ' ...
                      'QUANTIZER/RESET.']);
                error(msg);
            end
            % Get the value associated with the property
            loopcounter=loopcounter+1;
            if loopcounter>length(varargin)
              error('Invalid parameter/value pair arguments');
            end
            value=varargin{loopcounter};
            if ischar(value)
              % Allow abbreviations on values
              ind = strmatch(lower(value),names);
              if length(ind)==1
                value = names{ind};
              end
            end
        end
    end
  end
  
  % At this point, the property has been determined, and we parse the value
  if ~isjava(value) & isnumeric(value)
    d = size(value);
    msg=pvcheck(property,value,'format');error(msg);
    if ndims(d) > 2 | min(d) ~= 1 | max(d) ~= 2
      error('Format must be a vector of length 2.');
    elseif ~isreal(value)
      error('Format must be a real-valued vector');
    elseif any(value - floor(value))
      error('Format values must be integers');
    elseif value(1)<value(2)
      error(sprintf(['Wordlength (the first format element) ',...
            'cannot be smaller than \nthe second format element.']));
    end
    q.format = value(:)';  % Make it a row
    q = createjavaobject(q);
  elseif ischar(value)
    switch value
      case modes
        msg=pvcheck(property,value,'mode');error(msg);
        q.mode = value;
        q = createjavaobject(q);
      case overflowmodes
        msg=pvcheck(property,value,'overflowmode');error(msg);
        q.overflowmode = value;
        q = createjavaobject(q);
      case roundmodes
        msg=pvcheck(property,value,'roundmode');error(msg);
        q.roundmode = value;
        q = createjavaobject(q);
      otherwise
        if ~isempty(value)
          error([value(1,:),' is an invalid value for a QUANTIZER object.']);
        else
          error(['An empty string is an invalid value for a QUANTIZER' ...
                ' object.']);
        end
    end
  elseif isa(value,'struct')
    % set(q, ..., a, ...) where a is a struct.
    % Call like the pn,pv cell
    pn=fieldnames(value);
    pv=struct2cell(value);
    c = {pn{:};pv{:}}; % Interleave parameters and values
    set(q,c{:});    
  elseif isa(value,'cell')
    % set(q, ..., pn,pv, ...)
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
    set(q,c{:});
  elseif isa(value,[packagename,'Dbl'])
    q.mode = 'double';
    q.quantizer = value;
  elseif isa(value,[packagename,'Single'])
    q.mode = 'single';
    q.quantizer = value;
  elseif isa(value,[packagename,'Flceil'])
    q.mode = 'float';
    q.roundmode = 'ceil';
    q.format = [value.wordlength value.exponentlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Flconvergent'])
    q.mode = 'float';
    q.roundmode = 'convergent';
    q.format = [value.wordlength value.exponentlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Flfix'])
    q.mode = 'float';
    q.roundmode = 'fix';
    q.format = [value.wordlength value.exponentlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Flfloor'])
    q.mode = 'float';
    q.roundmode = 'floor';
    q.format = [value.wordlength value.exponentlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Flround'])
    q.mode = 'float';
    q.roundmode = 'round';
    q.format = [value.wordlength value.exponentlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixceilsaturate'])
    q.mode = 'fixed';
    q.roundmode = 'ceil';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixceilwrap'])
    q.mode = 'fixed';
    q.roundmode = 'ceil';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixconvergentsaturate'])
    q.mode = 'fixed';
    q.roundmode = 'convergent';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixconvergentwrap'])
    q.mode = 'fixed';
    q.roundmode = 'convergent';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixfixsaturate'])
    q.mode = 'fixed';
    q.roundmode = 'fix';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixfixwrap'])
    q.mode = 'fixed';
    q.roundmode = 'fix';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixfloorsaturate'])
    q.mode = 'fixed';
    q.roundmode = 'floor';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixfloorwrap'])
    q.mode = 'fixed';
    q.roundmode = 'floor';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixroundsaturate'])
    q.mode = 'fixed';
    q.roundmode = 'round';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Sfixroundwrap'])
    q.mode = 'fixed';
    q.roundmode = 'round';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixceilsaturate'])
    q.mode = 'ufixed';
    q.roundmode = 'ceil';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixceilwrap'])
    q.mode = 'ufixed';
    q.roundmode = 'ceil';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixconvergentsaturate'])
    q.mode = 'ufixed';
    q.roundmode = 'convergent';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixconvergentwrap'])
    q.mode = 'ufixed';
    q.roundmode = 'convergent';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixfixsaturate'])
    q.mode = 'ufixed';
    q.roundmode = 'fix';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixfixwrap'])
    q.mode = 'ufixed';
    q.roundmode = 'fix';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixfloorsaturate'])
    q.mode = 'ufixed';
    q.roundmode = 'floor';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixfloorwrap'])
    q.mode = 'ufixed';
    q.roundmode = 'floor';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixroundsaturate'])
    q.mode = 'ufixed';
    q.roundmode = 'round';
    q.overflowmode = 'saturate';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  elseif isa(value,[packagename,'Ufixroundwrap'])
    q.mode = 'ufixed';
    q.roundmode = 'round';
    q.overflowmode = 'wrap';
    q.format = [value.wordlength value.fractionlength];
    q.quantizer = value;
  else
    error(['Values of class ',class(value),[' are not allowed in ' ...
            'QUANTIZER objects.  Values must be either a vector of '...
            'length 2, or a string.']]);
  end
  loopcounter = loopcounter + 1;
end % while loopcounter <= length(varargin)

if nargout==0
  % set(q,...)
  assignin('caller',inputname(1),q)
else
  % q1 = set(q,...)
  % [q1,q2,...] = set(q,...)
  for k=1:nargout
    varargout{k} = q;
  end
end

function q = createjavaobject(q);
packagename = 'com.mathworks.toolbox.filterdesign.';
switch q.mode
  case 'fixed'
    q.quantizer = javaObject([packagename, 'Sfix', q.roundmode, ...
          q.overflowmode], q.format);
  case 'ufixed'
    q.quantizer = javaObject([packagename, 'Ufix', q.roundmode, ...
          q.overflowmode], q.format);
  case 'float'
    q.quantizer = javaObject([packagename, 'Fl', q.roundmode], q.format);
  case 'double'
    q.quantizer = javaObject([packagename, 'Dbl']);
  case 'single'
    q.quantizer = javaObject([packagename, 'Single']);
end

function  msg=pvcheck(property,value,validproperty);

msg='';
if ~(strcmpi(property,'')|strcmpi(property,validproperty))
  if isnumeric(value)
    valuestr=['[',num2str(value(1,:)),']'];
  else
    valuestr=['''',value(1,:),''''];
  end
  msg=['(''',property,''',', valuestr,')' ...
        ' is an invalid (Property, Value) pair for a QUANTIZER object.'];
end
