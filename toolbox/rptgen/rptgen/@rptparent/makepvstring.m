function outCell=makepvstring(anObject,inStruct)
%MAKEPVSTRING creates a property/value string

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:20 $

if isempty(inStruct)
   outCell={};
else
   ListString=evalc('disp(inStruct)');
   
   ListString=strrep(ListString,'''','''''');
   
   LastLoc=max(find(ListString~=abs(sprintf('\n'))))+1;
   ListString=[ '{''' ...
         strrep(ListString(1:LastLoc),sprintf('\n'),''',''') ...
         '''}' ];
   ListString=eval(ListString);
   outCell={ListString{1:length(fieldnames(inStruct))}};
end