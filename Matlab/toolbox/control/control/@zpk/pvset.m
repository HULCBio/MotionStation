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
%   $Revision: 1.24 $  $Date: 2002/04/10 06:12:06 $

ni = nargin;
zpkflag = 0;
%SetVar = 0;
SetTs = 0;
LTIProps = zeros(1,ni-1);  % 1 for LTI P/V pairs
OldVar=sys.Variable;
OldDisplayFormat=sys.DisplayFormat;
for i=1:2:ni-1,
   % Set each Property Name/Value pair in turn. 
   Property = varargin{i};
   Value = varargin{i+1};
   
   % Perform assignment
   switch Property
   case 'z'
      if isa(Value,'double'),  Value = {Value};  end
      sys.z = Value;   
      zpkflag = zpkflag + 1;
      
   case 'p'
      if isa(Value,'double'),  Value = {Value};  end
      sys.p = Value;
      zpkflag = zpkflag + 1;
      
   case 'k'
      sys.k = Value;
      zpkflag = zpkflag + 1;
      
   case 'Variable'
      if ~isstr(Value),
         error('Property "Variable" must be set to a string.');
      elseif ~any(strcmp(Value,{'s';'p';'z';'z^-1';'q'}))
         error('Invalid value for property "Variable"');
      end
      OldVar = sys.Variable;
      sys.Variable = Value;
      %SetVar = 1;
   case 'DisplayFormat'
      if ~ischar(Value),
         error('Property "DisplayFormat" must be set to a string.');
      elseif ~any(strcmp(Value(1),{'r';'t';'f'}))
         error('Invalid value for property "DisplayFormat"');
      end
      OldDisplayFormat = sys.DisplayFormat;
      switch Value(1)
      case 'r'
        sys.DisplayFormat = 'roots';
      case 't'
        sys.DisplayFormat = 'time-constant';
      case 'f'
        sys.DisplayFormat = 'frequency';
      end
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
% (1) Variable vs. Sampling time:
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
      if ~strcmpi(OldVar,var)
         warning(sprintf(...
            'Variable %s inappropriate for continuous systems.',var))
      end
   end

elseif Ts~=0 & sp,
   % Second conflicting case: nonzero Ts with Variable 's' or 'p'
   sys.Variable = 'z';   % default
   if ~strcmpi(OldVar,var)
      % Variable was set to 's' or 'p': revert to old value if adequate
      warning(sprintf(...
         'Variable %s inappropriate for discrete systems.',var))
      if any(strcmp(OldVar,{'z';'z^-1';'q'})),
         sys.Variable = OldVar;
      end
   end
end

if (strcmpi(sys.Variable,'z^-1') | strcmpi(sys.Variable,'q')) & (strcmpi(sys.DisplayFormat(1),'f') | strcmpi(sys.DisplayFormat(1),'t'))
    %Illegal display form for z^-1 or q
    if  ~strcmp(sys.Variable,OldVar) &  strcmpi(sys.DisplayFormat(1), OldDisplayFormat(1))
        warning(sprintf(...
         'Variable type %s is illegal for @zpk models in %s form. Reverting to %s',sys.Variable, sys.DisplayFormat, OldVar));
        sys.Variable=OldVar; %reset the variable back to its previous legal form
    elseif  ~strcmpi(sys.DisplayFormat(1),OldDisplayFormat(1)) & strcmpi(sys.Variable,OldVar)
        warning(sprintf(...
         'Variable type %s is illegal for @zpk models in %s form. Reverting to %s form',sys.Variable, sys.DisplayFormat, OldDisplayFormat));
        sys.DisplayFormat=OldDisplayFormat; %reset the DisplayFormat back to its previous legal form
    else
        warning(sprintf(...
         'Variable type %s is illegal for @zpk models in %s form. Reverting to variable %s in %s form',sys.Variable, sys.DisplayFormat, OldVar, OldDisplayFormat));
        sys.DisplayFormat = OldDisplayFormat; 
        sys.Variable = OldVar; 
    end
end
% (2) Z,P,K consistency
sys = zpkcheck(sys,zpkflag);

% (3) Check LTI property consistency
sys.lti = lticheck(sys.lti,size(sys.k));


