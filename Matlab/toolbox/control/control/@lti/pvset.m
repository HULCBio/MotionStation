function sys = pvset(sys,varargin)
%PVSET  Set properties of LTI models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $ $Date: 2004/04/10 23:13:22 $

% RE: PVSET is performing object-specific property value setting
%     for the generic LTI/SET method. It expects true property names.

for i=1:2:nargin-1,
   % Set each PV pair in turn
   Property = varargin{i};
   Value = varargin{i+1};
   if strcmp(Property,'Td'),
      % Trap for obsolete TD property
      Property = 'InputDelay';
      warning(sprintf('%s\n         %s',...
            'LTI property TD is obsolete. Use ''InputDelay'' or ''ioDelay''.',...
            'See LTIPROPS for details.'))
   end
   
   % Set property values
   switch Property      
   case 'InputDelay',
      if ~isreal(Value) | ~all(isfinite(Value(:))) | any(Value(:)<0),
         error('Input delay times must be non negative numbers.')
      end
      sys.InputDelay = Value;
         
   case 'OutputDelay',
      if ~isreal(Value) | ~all(isfinite(Value(:))) | any(Value(:)<0),
         error('Output delay times must be non negative numbers.')
      end
      sys.OutputDelay = Value;
         
   case 'ioDelay'
      if ~isreal(Value) | ~all(isfinite(Value(:))) | any(Value(:)<0),
         error('I/O delay times must be non negative numbers.')
      end
      sys.ioDelay = Value;

   case 'Ts'
      if isempty(Value),  
         Value = -1;  
      end
      if ndims(Value)>2 | length(Value)~=1 | ~isreal(Value) | ~isfinite(Value),
         error('Sample time must be a real number.')
      elseif Value<0 & Value~=-1,
         error('Negative sample time not allowed (except Ts=-1 to mean unspecified).');
      end
      sys.Ts = Value;

   case 'InputName'
      sys.InputName = ChannelNameCheck(Value,'InputName');
 
   case 'OutputName'
      sys.OutputName = ChannelNameCheck(Value,'OutputName');
        
   case 'InputGroup'
      if isempty(Value)
         Value = struct;
      end
      % All error checking deferred to LTICHECK
      sys.InputGroup = Value;
      
   case 'OutputGroup'
      if isempty(Value)
         Value = struct;
      end
      % All error checking deferred to LTICHECK
      sys.OutputGroup = Value;

   case 'Notes'
      if isstr(Value),  
         Value = {Value};  
      end
      sys.Notes = Value;

   case 'UserData'
      sys.UserData = Value;

   otherwise
      % This should not happen
      error('Unexpected property name.')

   end % switch
end % for

% Note: size consistency checks deferred to ss/pvset, tf/pvset,...
%       to allow resizing of the I/O dimensions


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name)
% Checks specified I/O names
if isempty(a),  
   a = a(:);   % make 0x1
   return  
end

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(a) & ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) & ndims(a)==2 & min(size(a))==1,
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) | any(cellfun('size',a,1)>1),
      error(sprintf('All cell entries of %s must be single-line strings.',Name))
   end
   
else
   error(sprintf('%s %s\n%s',Name,...
      'must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])',...
      'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'))
end

% Make sure that nonempty I/O names are unique
as = sortrows(char(a));
repeat = (any(as~=' ',2) & all(as==strvcat(as(2:end,:),' '),2));
if any(repeat),
   warning(sprintf('I/O names are not unique.'))
end
