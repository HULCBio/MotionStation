function cleanList=excludesystems(z,rawList)
%EXCLUDESYSTEMS removes non-reportable systems from a list
%   OUTLIST=EXCLUDESYSTEMS(ZSLMETHODS,INLIST)


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:30 $

if ~iscell(rawList)
   rawList={rawList};
end

allBadTypes={
   {'MaskType','Stateflow'}
};

badList={};

for i=1:length(allBadTypes)
   try
      thisBad=find_system(rawList,...
         'SearchDepth',0,...
         allBadTypes{i}{:});
   catch
      thisBad={};
   end
   badList=[badList;thisBad];
end

cleanList=setdiff(rawList,badList);

