function t=set(t,varargin)
%SET set properties

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:39 $

for i=1:2:length(varargin)-1
   value=varargin{i+1};
   switch lower(varargin{i})
   case 'tag'
      t.tag=value;
   case 'data'
      t.data=value;
   case 'att'
      t.att=value;
   case 'indent'
      t.opt(1)=LocLogicalValue(value); 
   case 'endtag'
      t.opt(2)=LocLogicalValue(value); 
   case 'expanded'
      t.opt(3)=LocLogicalValue(value); 
   case 'issgml'
      t.opt(4)=LocLogicalValue(value);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logicalValue=LocLogicalValue(anyValue)

if islogical(anyValue) | isnumeric(anyValue)
   logicalValue=anyValue;
elseif ischar(anyValue)
   switch anyValue
   case {'off' 'false' 'no'}
      logicalValue=false;
   case {'on' 'true' 'yes'}
      logicalValue=true;
   otherwise
      error('Bad value for logical property')
   end
else
   error('Bad value for logical property')
end
