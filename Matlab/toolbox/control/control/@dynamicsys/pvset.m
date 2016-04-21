function sys = pvset(sys,varargin)
%PVSET  Set properties of LTI models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:12:46 $

% RE: PVSET is performing object-specific property value setting
%     for the generic LTI/SET method. It expects true property names.

for i=1:2:nargin-1,
   % Set each PV pair in turn
   Property = varargin{i};
   Value = varargin{i+1};

   % Set property values
   switch Property
      case 'InputName'
         if isempty(Value)
            % Interpret as clearing the input names
            sys.InputName(:) = {''};
         else
            sys.InputName = ChannelNameCheck(Value,'InputName');
         end

      case 'OutputName'
         if isempty(Value)
            sys.OutputName(:) = {''};
         else
            sys.OutputName = ChannelNameCheck(Value,'OutputName');
         end

      case 'InputGroup'
         if isempty(Value)
            Value = struct;
         end
         % All error checking deferred to CHECKSYS
         sys.InputGroup = Value;
         
      case 'OutputGroup'
         if isempty(Value)
            Value = struct;
         end
         % All error checking deferred to CHECKSYS
         sys.OutputGroup = Value;
         
      case 'Name'
         if ~ischar(Value)
            error('Name property expects a string value.')
         end
         sys.Name = Value;
         
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name)
% Checks specified I/O names

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(a) && ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) && isvector(a)
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1),
      error('All cell entries of %s must be single-line strings.',Name)
   end
   
else
   error('%s %s\n%s',Name,...
      'must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])',...
      'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).')
end

% Make sure that nonempty I/O names are unique
as = sortrows(char(a));
repeat = (any(as~=' ',2) & all(as==strvcat(as(2:end,:),' '),2));
if any(repeat),
   warning('control:ioNameRepeat','I/O names are not unique.')
end
   
