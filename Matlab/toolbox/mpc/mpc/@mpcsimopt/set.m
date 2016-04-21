function Out = set(mpcsimopt,varargin)
%SET  Set properties of mpcsimopt objects.
%
%   SET(mpcsimopt,'PropertyName',VALUE) sets the property 'PropertyName'
%   of mpcsimopt to the value VALUE.  An equivalent syntax 
%   is 
%       mpcsimopt.PropertyName = VALUE .
%
%   SET(mpcsimopt,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   property values with a single statement.
%
%   SET(mpcsimopt,'Property') displays legitimate values for the specified
%   property of mpcsimopt.
%
%   SET(mpcsimopt) displays all properties of mpcsimopt and their admissible 
%   values.  
%
%   See also GET.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/10 23:35:26 $   

ni = nargin;
no = nargout;
if ~isa(mpcsimopt,'mpcsimopt'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',mpcsimopt,varargin{:});
   return
elseif no & ni>2,
   error('mpc:mpcsimoptset:out','Output argument allowed only in SET(mpcsimopt) or SET(mpcsimopt,Property)');
end

% Get properties and their admissible values when needed
if ni<=2,
   [AllProps,AsgnValues] = pnames(mpcsimopt);
else
   AllProps = pnames(mpcsimopt);
end

% Handle read-only cases
if ni==1,
   % SET(mpcsimopt) or S = SET(mpcsimopt)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues));
   end
   return

elseif ni==2,
   % SET(mpcsimopt,'Property') or STR = SET(mpcsimopt,'Property')
   
   Property = varargin{1};
   if ~ischar(Property),
      error('mpc:mpcsimoptset:name','Property names must be single-line strings.')
   end

   % Return admissible property value(s)
   imatch = strmatch(lower(Property),lower(AllProps));
   aux=PropMatchCheck(length(imatch),Property);
   if ~isempty(aux),
       error('mpc:mpcsimoptset:match',aux);
   end
   if no,
      Out = AsgnValues{imatch};
   else
      disp(AsgnValues{imatch})
   end
   return

end


% Now left with SET(mpcsimopt,'Prop1',Value1, ...)

name = inputname(1);
if isempty(name),
   error('mpc:mpcsimoptset:first','First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
   error('mpc:mpcsimoptset:pair','Property/value pairs must come in even number.')
end

for i=1:2:ni-1,
   % Set each PV pair in turn
   PropStr = varargin{i};
   if ~isstr(PropStr),
      error('mpc:mpcsimoptset:string','Property names must be single-line strings.')
   end
   
   propstr=lower(PropStr);
      
   imatch = strmatch(propstr,lower(AllProps));
   aux=PropMatchCheck(length(imatch),PropStr);
   if ~isempty(aux),
      error('mpc:mpcsimoptset:match',aux);
   end
   Property = AllProps{imatch};
   Value = varargin{i+1};
   
   % Just sets what was required, will check later on when all 
   % properties have been set
   
   %eval(['mpcsimopt.' Property '=Value;']);
   mpcsimopt.(Property)=Value;
end   

% Finally, assign mpcsimopt in caller's workspace
assignin('caller',name,mpcsimopt);


% subfunction PropMatchCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errmsg = PropMatchCheck(nhits,Property)
% Issues a standardized error message when the property name 
% PROPERTY is not uniquely matched.

if nhits==1,
   errmsg = '';
elseif nhits==0,
   errmsg = ['Invalid property name "' Property '".']; 
else
   errmsg = ['Ambiguous property name "' Property '". Supply more characters.'];
end
