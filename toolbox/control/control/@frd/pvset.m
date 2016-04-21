function sys = pvset(sys,varargin)
%PVSET  Set properties of LTI models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Author(s): P. Gahinet, S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 06:16:55 $

ni = nargin;
valueChange = 0;
unitsChanged = 0;
freqChanged = 0;
LTIProps = zeros(1,ni-1);  % 1 for LTI P/V pairs

for i=1:2:ni-1,
   % Set each Property Name/Value pair in turn. 
   Property = varargin{i};
   Value = varargin{i+1};
   
   % Perform assignment
   switch Property
   case 'Frequency'
      if ~isa(Value,'double')
         error('The property "Frequency" must be set to a vector of doubles.');
      end
      sys.Frequency = Value;   
      valueChange = valueChange + 1;
      freqChanged = 1;
      
   case 'ResponseData'
      if ~isa(Value,'double')
         error('The property "ResponseData" must be set to an array of doubles.');
      end
      sys.ResponseData = Value;
      valueChange = valueChange + 2;
      
   case 'Units'
      if ~isstr(Value),
         error('The property "Units" must be set to a string.');
      elseif strncmpi(Value,'r',1)
         sys.Units = 'rad/s';
      elseif strncmpi(Value,'h',1)
         sys.Units = 'Hz';
      else
         error('"Units" property must be either ''rad/s'' or ''Hz''');
      end
      unitsChanged = 1;
      
   otherwise
      LTIProps([i i+1]) = 1;
      varargin{i} = Property;
      
   end % switch
end % for

% Set all LTI properties at once
% RE: At this point, VARARGIN contains only valid LTI properties in full lower-case format
LTIProps = find(LTIProps);
if ~isempty(LTIProps)
   sys.lti = pvset(sys.lti,varargin{LTIProps});
end

% EXIT CHECKS:

% FREQ value/units check
if unitsChanged & ~freqChanged
   warning(sprintf('%s\n%s','''Units'' property changed. To convert FRD Units and', ...
      'automatically scale frequency points, use CHGUNITS instead.'));
end

% FREQ/RESPONSEDATA check
if valueChange,
   sys = frdcheck(sys,valueChange);
end

% Check LTI property consistency
sizes = size(sys.ResponseData);
sys.lti = lticheck(sys.lti,[sizes(1:2) sizes(4:end)]);
