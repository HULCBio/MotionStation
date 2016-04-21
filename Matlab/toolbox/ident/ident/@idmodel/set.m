function Out = set(sys,varargin)
%SET  Set properties of IDMODEL models.
%
%   SET(SYS,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the IDMODEL model SYS to the value VALUE.  An equivalent syntax 
%   is 
%       SYS.PropertyName = VALUE .
%
%   SET(SYS,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   IDMODEL property values with a single statement.
%
%   SET(SYS,'Property') displays legitimate values for the specified
%   property of SYS.
%
%   SET(SYS) displays all properties of SYS and their admissible 
%   values.  Type HELP IDPROPS for more details on IDMODEL properties.
%
%   Note: Resetting the sampling time does not alter the model data.
%         Use C2D or D2D for conversions between the continuous and 
%         discrete domains.
%
%   See also GET, IDHELP, IDPROPS.


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/04/10 23:17:37 $

ni = nargin;
no = nargout;

if ~isa(sys,'idmodel'),
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
      cell2struct(AsgnValues,AllProps,1)
      disp(sprintf(['\n  Type "idprops", "idprops %s", "idprops Algorithm",',...
            '\n  and "idprops EstimationInfo" for more details.',...
            '\n  IDHELP gives a micromanual for basic use of the properties'],...
         class(sys)))
   end
   
elseif ni==2,
   % SET(SYS,'Property') or STR = SET(SYS,'Property')
   % Return admissible property value(s)
   [dum,PropAlg,Typealg]=iddef('algorithm');
   AllProps=[AllProps;PropAlg'];
   AsgnValues=[AsgnValues;Typealg'];
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
 
   [dum,PropAlg]=iddef('algorithm');
   AllProps=[AllProps;PropAlg'];
   try
      for i=1:2:ni-1 
         varargin{i} = pnmatchd(varargin{i},AllProps,7); 
          if isa(varargin{i+1},'idmodel')&strcmp(varargin{i},'Focus')
              % this is to avoid that the set-command is redirected to the
              % wrong pvset in case a 'Focus' is to be set
              [a,b,c,d] = ssdata(varargin{i+1});
              varargin{i+1} = {a,b,c,d,pvget(varargin{i+1},'Ts')};
          end
      end
      sys = pvset(sys,varargin{:});
   catch
      error(lasterr)
   end
   
   % Assign sys in caller's workspace
   assignin('caller',sysname,sys)
end

