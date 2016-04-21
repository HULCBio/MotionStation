function Value = get(sys,Property)
%GET  Access/query IDMODEL property values.
%
%   VALUE = GET(SYS,'PropertyName') returns the value of the 
%   specified property of the IDMODEL model SYS.  An equivalent
%   syntax is 
%       VALUE = SYS.PropertyName .
%   
%   GET(SYS) displays all properties of SYS and their values.  
%   Type HELP IDPROPS for more detail on IDMODEL properties.
%
%   See also SET, TFDATA, ZPKDATA, SSDATA,  IDPROPS.

 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:09 $

% Generic GET method for all IDMODEL children.
% Uses the object-specific methods PNAMES and PVALUES
% to get the list of all public properties and their
% values (PNAMES and PVALUES must be defined for each 
% particular child object)

ni = nargin;
error(nargchk(1,2,ni));

if ni==2,
   % GET(SYS,'Property') or GET(SYS,{'Prop1','Prop2',...})
   CharProp = ischar(Property);
   if CharProp,
      Property = {Property};
   elseif ~iscellstr(Property)
      error('Property name must be a string or a cell vector of strings.')
   end
   
   % Get all public properties
   AllProps = pnames(sys); 
   [dum,AlgProp]=iddef('algorithm');
   AllProps=[AllProps;AlgProp'];

   % Loop over each queried property 
   Nq = prod(size(Property)); 
   Value = cell(1,Nq); 
   for i=1:Nq,
      % Find match for k-th property name and get corresponding value
      % RE: a) Must include all properties to detect multiple hits
      %     b) Limit comparison to first 7 chars (because of OutputName)
      try 
         Value{i} = pvget(sys,pnmatchd(Property{i},AllProps,7));
      catch
         error(lasterr)
      end
   end
   
   % Strip cell header if PROPERTY was a string
   if CharProp,
      Value = Value{1};
   end

elseif nargout,
   % STRUCT = GET(SYS)
   Value = cell2struct(pvget(sys),pnames(sys),1);
   
else
   % GET(SYS)
 %  PropStr = pnames(sys);
  % [ValStr] = pvget(sys);
 
 %disp(pvformat(PropStr,ValStr)) %LL: couldn't make this work
 cell2struct(pvget(sys),pnames(sys),1)
end
