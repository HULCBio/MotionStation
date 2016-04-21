function sys = pvset(sys,varargin)
%PVSET  Set properties of LTI models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.23 $  $Date: 2002/04/10 06:07:09 $

ni = nargin;
numden = 0;
SetVar = 0;
SetTs = 0;
LTIProps = zeros(1,ni-1);  % 1 for LTI P/V pairs

for i=1:2:ni-1,
   % Set each Property Name/Value pair in turn. 
   Property = varargin{i};
   Value = varargin{i+1};
   
   % Perform assignment
   switch Property
   case 'num'
      if isa(Value,'double'),  
         Value = {Value};  
      end
      sys.num = Value;   
      numden = numden + 1;
      
   case 'den'
      if isa(Value,'double'),  
         Value = {Value};  
      end
      sys.den = Value;
      numden = numden + 1;
      
   case 'Variable'
      if ~isstr(Value),
         error('The property "Variable" must be set to a string.');
      elseif ~any(strcmp(Value,{'s';'p';'z';'z^-1';'q'})),
         error('Invalid value for "Variable" property.');
      end
      OldVar = sys.Variable;
      sys.Variable = Value;
      SetVar = 1;
      
   otherwise
      LTIProps([i i+1]) = 1;
      SetTs = SetTs | strcmp(Property,'Ts');
      
   end % switch
end % for

% Set all LTI properties at once
% RE: At this point, VARARGIN contains only valid LTI properties in full lower-case format
LTIProps = find(LTIProps);
if ~isempty(LTIProps)
   sys.lti = pvset(sys.lti,varargin{LTIProps});
end

% EXIT CHECKS:
% (1) Variable vs. sampling time:
var = sys.Variable;
sp = strcmp(var,'s') | strcmp(var,'p');
Ts = getst(sys.lti); 

if Ts==0 & ~sp,
   % First conflicting case: Ts = 0 with Variable 'z', 'z^-1', or 'q'
   if ~SetTs,
      % Variable 'z', 'q', 'z^-1' used to mean "discrete". Set Ts to -1
      sys.lti = pvset(sys.lti,'Ts',-1);
   else
      % Ts explicitly set to zero: reset Variable to default 's'
      sys.Variable = 's';
      if SetVar,
         warning(sprintf(...
            'Variable %s inappropriate for continuous systems.',var))
      end
   end

elseif Ts~=0 & sp,
   % Second conflicting case: nonzero Ts with Variable 's' or 'p'
   sys.Variable = 'z';   % default
   if SetVar,
      % Variable was set to 's' or 'p': revert to old value if adequate
      warning(sprintf(...
         'Variable %s inappropriate for discrete systems.',var))
      if any(strcmp(OldVar,{'z';'z^-1';'q'})),
         sys.Variable = OldVar;
      end
   end
end

% (2) NUM/DEN check and padding
if numden,
   sys = ndcheck(sys,numden);
   [sys.num,sys.den] = ndpad(sys.num,sys.den,sys.Variable);
end

% (3) Check LTI property consistency
sys.lti = lticheck(sys.lti,size(sys.num));

