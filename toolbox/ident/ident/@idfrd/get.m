function Value = get(sys,Property)
%GET  Access/query IDFRD property values.
%
%   VALUE = GET(SYS,'Property')  returns the value of the specified
%   property of the IDMODEL model SYS.
%
%   ValueList = GET(SYS) Returns a cell array of properties and their 
%   values 
%
%   Without left-hand argument,  GET(SYS)  displays all properties 
%   of SYS and their values.
%
%   See also  SET 

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/04/11 12:44:32 $

ni = nargin;
error(nargchk(1,2,ni));

% Get all public properties and their values
AllProps = pnames(sys);
AllValues = pvalues(sys);

% Handle various cases
if ni==2,
   % GET(SYS,'Property'
   if ischar(Property)                  
% $$$       [imatch,status] = pmatchm(AllProps,Property); 
% $$$       error(status)
% $$$       Value=AllValues{imatch};
     try
       Value = pvget(sys,pnmatchd(Property,AllProps,7));
     catch
       error(lasterr)
       end
   else %not isstr prop
      % GET(SYS,{'Prop1','Prop2',...})
      np = prod(size(Property));
      Value = cell(1,np);
      for i=1:np,
% $$$          [imatch,status] = pmatchm(AllProps,Property{i});
% $$$          error(status)
% $$$          Value{i} = AllValues{imatch};
	 try 
         Value{i} = pvget(sys,pnmatchd(Property{i},AllProps,7));
      catch
         error(lasterr)
      end
      end
   end
   
elseif nargout, % i.e. nargin ne 2
   % STRUCT = GET(SYS)
   Value = cell2struct(AllValues,AllProps(1:length(AllValues)),1);
   
else 
   % GET(SYS)
   cell2struct(AllValues,AllProps(1:length(AllValues)),1)
end

% end idfrd/get.m
