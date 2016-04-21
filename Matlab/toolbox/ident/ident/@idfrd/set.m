function Out = set(sys,varargin)
%SET  Set properties of IDFRD models.
%
%   SET(SYS,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the IDFRD model SYS to the value VALUE.  An equivalent syntax 
%   is 
%       SYS.PropertyName = VALUE .
%
%   SET(SYS,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   IDFRD property values with a single statement.
%
%   SET(SYS,'Property') displays legitimate values for the specified
%   property of SYS.
%
%   SET(SYS) displays all properties of SYS and their admissible 
%   values.  Type IDPROPS IDFRD for more details on IDFRD properties.
%
%   Note: Resetting the sampling time does not alter the model data.
%         Use C2D or D2D for conversions between the continuous and 
%         discrete domains.
%
%   See also GET, IDPROPS IDFRD


%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/25 10:56:39 $

ni = nargin;
no = nargout;
 
if ~isa(sys,'idfrd'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',sys,varargin{:});
   return
elseif no & ni>2,
   error('Output argument allowed only in SET(SYS) or SET(SYS,Property).');
end

% Get public properties and their assignable values
[AllProps,AsgnValues] = pnames(sys);

% Handle read-only cases
if ni==1,
   % SET(SYS) or S = SET(SYS)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      %settest(sys)
      %disp(pvformat(AllProps,AsgnValues)) %% LL Couldn't make this work
      cell2struct(AsgnValues,AllProps,1)
      disp(sprintf('\n  Type "idprops", "idprops %s", for more details.',class(sys)))
   end
   
elseif ni==2,
   % SET(SYS,'Property') or STR = SET(SYS,'Property')
   % Return admissible property value(s)
   try
      [Property,imatch] = pnmatchd(varargin{1},AllProps,7);
      if no,
         Out = AsgnValues{imatch};
      else
         disp(AsgnValues{imatch})
      end
   catch 
      error(lasterr)
   end
   
else
   % SET(SYS,'Prop1',Value1, ...)
    AllProps = pnames(sys);

   sysname = inputname(1);
   if isempty(sysname),
      error('First argument to SET must be a named variable.')
   elseif rem(ni-1,2)~=0,
      error('Property/value pairs must come in even number.')
   end
   
   % Match specified property names against list of public properties and
   % set property values at object level
   % RE: a) Include all properties to appropriately detect multiple matches
   %     b) Limit comparison to first 6 chars (because of NoiseModel)
   try
      for i=1:2:ni-1 
         varargin{i} = pnmatchd(varargin{i},AllProps,7); 
      end
      sys = pvset(sys,varargin{:});
   catch
      error(lasterr)
   end
   
   % Assign sys in caller's workspace
   assignin('caller',sysname,sys)
   
end





