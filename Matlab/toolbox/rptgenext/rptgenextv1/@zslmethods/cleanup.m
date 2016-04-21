function cleanup(z)
%CLEANUP removes models created during report generation
%   CLEANUP(Z) bdcloses all systems currently
%   open which are not listed in Z.PreRunOpenModels
%   PreRunOpenModels is initialized in ZSLMETHODS/INITIALIZE
%
%   See also INITIALIZE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:28 $


CloseModels(z);
%CloseTlcHandles(z);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseModels(z);

okModels=subsref(z,substruct('.','PreRunOpenModels'));

if any(isnan(okModels))
   okModels=[];
end

allModels=find_system(0,...
   'SearchDepth',1,...
   'type','block_diagram',...
   'blockdiagramtype','model');

badModels=setdiff(allModels,okModels);

for i=1:length(badModels)
   try
      bdclose(badModels(i));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseTlcHandles(z);


okContext=subsref(z,substruct('.','PreRunOpenTlcContext'));

if any(isnan(okContext))
   okContext=[];
end

try
   allContext=tlc('list');
catch
   allContext=[];
end

badContext=setdiff(allContext,okContext);

for i=1:length(badContext)
   try
      tlc('close',badContext(i));
   end
end
