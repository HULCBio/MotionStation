function Out = set(sys,varargin)
%SET  Set properties of LTI models.
%
%   SET(SYS,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the LTI model SYS to the value VALUE.  An equivalent syntax 
%   is 
%       SYS.PropertyName = VALUE .
%
%   SET(SYS,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   LTI property values with a single statement.
%
%   SET(SYS,'Property') displays legitimate values for the specified
%   property of SYS.
%
%   SET(SYS) displays all properties of SYS and their admissible 
%   values.  Type HELP LTIPROPS for more details on LTI properties.
%
%   Note: Resetting the sampling time does not alter the model data.
%         Use C2D or D2D for conversions between the continuous and 
%         discrete domains.
%
%   See also GET, LTIMODELS, LTIPROPS.

%   Author(s): A. Potvin, P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 05:48:22 $

ni = nargin;
no = nargout;
if ~isa(sys,'lti'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',sys,varargin{:});
   return
elseif no & ni>2,
   error('Output argument allowed only in SET(SYS) or SET(SYS,Property).');
end

% Get public properties and their assignable values
if ni<=2,
   [AllProps,AsgnValues] = pnames(sys);
else
   % Add obsolete property Td   
   AllProps = [pnames(sys) ; {'Td'}];
end


% Handle read-only cases
if ni==1,
   % SET(SYS) or S = SET(SYS)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      disp(pvformat(AllProps,AsgnValues))
      disp(sprintf('\nType "ltiprops %s" for more details.',class(sys)))
   end
   
elseif ni==2,
   % SET(SYS,'Property') or STR = SET(SYS,'Property')
   % Return admissible property value(s)
   try
      [Property,imatch] = pnmatch(varargin{1},AllProps,7);
      if no,
         Out = AsgnValues{imatch};
      else
         disp(AsgnValues{imatch})
      end
   catch 
      rethrow(lasterror)
   end
   
else
   % SET(SYS,'Prop1',Value1, ...)
   sysname = inputname(1);
   if isempty(sysname),
      error('First argument to SET must be a named variable.')
   elseif rem(ni-1,2)~=0,
      error('Property/value pairs must come in even number.')
   end
   
   % Match specified property names against list of public properties and
   % set property values at object level
   % RE: a) Include all properties to appropriately detect multiple matches
   %     b) Limit comparison to first 7 chars (because of iodelaymatrix)
   try
      for i=1:2:ni-1,
         varargin{i} = pnmatch(varargin{i},AllProps,7);
      end
      sys = pvset(sys,varargin{:});
   catch
      rethrow(lasterror)
   end
   
   % Assign sys in caller's workspace
   assignin('caller',sysname,sys)
   
end

