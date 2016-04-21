function bList=searchblocktype(z,sortCells,context)
%SEARCHBLOCKTYPE looks for blocks of a certain type 
%   BLOCKLIST=SEARCHBLOCKTYPE(ZSLMETHODS,SEARCHCELLS,SCOPE)
%   CONTEXTSTRINGS=SEARCHBLOCKTYPE(ZSLMETHODS,BLOCKSTRING)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:52 $

if nargin==2
   
   bList.contextCode={
      'System'
      'Model'
      'Signal'
      'Block'
      ''
   };
   bList.contextName={
      sprintf('All %ss in current system',sortCells)
      sprintf('All reported %ss in current model',sortCells)
      sprintf('All %ss connected to current signal',sortCells) 
      sprintf('Current block if it is a %s' ,sortCells)   % may need to fix the article
      sprintf('All %ss in all models',sortCells)
   }; 
   
   % make the English grammar correct
   if any(strcmp({'a' 'e' 'i' 'o' 'u'},sortCells(1)))
      bList.contextName{4}=sprintf('Current block if it is an %s' ,sortCells);
   end
   
   
else
   switch context
   case 'System'
      sysName={subsref(z,substruct('.','System'))};
      contextFind={sysName,...
            'SearchDepth',1};
      isExclude=logical(1);
      
   case 'Signal'
      contextFind={loopblock(z,'$alphabetical','Signal'),...
            'SearchDepth',0};
      isExclude=logical(0);
      
   case 'Block'
      contextFind={{subsref(z,substruct('.','Block'))},...
            'SearchDepth',0};
      isExclude=logical(0);
      
   case 'Model'
      contextFind={subsref(z,substruct('.','ReportedBlockList')),...
            'SearchDepth',0};
      isExclude=logical(0);
      
   otherwise
      mList=find_system('SearchDepth',1,...
         'BlockDiagramType','model');
      contextFind={mList,...
            'FollowLinks','off',...
            'LookUnderMasks','graphical'};
      isExclude=logical(0);
      
   end
   
   bList=find_system(contextFind{:},...
      'Type','block',...
      sortCells{:});
   
   if isExclude
      %prevent current system from being included in
      %the returned block list
      bList=setdiff(bList,sysName);
   end
   
end



