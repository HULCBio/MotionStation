function sList=loopsystem(c,sortBy,blockScope)
%LOOPSYSTEM loop over systems
%   SYSLIST=LOOPSYSTEM(C,SORTBY,CONTEXT)
%     Valid SORTBY values are 
%          $numBlocks - number of blocks in system
%          $alphabetical - system name
%          $depth - depth of system
%     Valid CONTEXT values are
%          System - just returns current system
%          Signal - just returns current system
%          Block  - just returns current system 
%          Model  - returns a list of looped systems
%                   in the current model.  (defined
%                   in csl_mdl_loop
%
%          If a cell array is used for the CONTEXT input,
%          LOOPSYSTEM will not try to derive the list of
%          systems to be returned and will just sort the
%          input list.
%
%    See also CSL_MDL_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:44 $

if nargin==1
   sList.sortCode={
      '$numBlocks'
      '$systemalpha'
      '$depth'
      '$none'
   };
   
   sList.sortName={
      'By number of blocks in system'
      'Alphabetically by system name'
      'By system depth'
      'No sort'
   };
   
   sList.contextCode={
      'System'
      'Model'
      'Signal'
      'Block'
      ''
   };
   sList.contextName={
      sprintf('Current system')
      sprintf('Reported systems in current model')
      sprintf('Current signal''s parent system')
      sprintf('Current block''s parent system')
      sprintf('All systems in all models')
   };
   
else
   z=zslmethods;
   
   if iscell(blockScope)
      sList=blockScope;
   else
      switch blockScope
      case {'System' 'Signal' 'Block'}
         sList={subsref(z,substruct('.','System'))};
      case 'Model'
         sList=subsref(z,substruct('.','ReportedSystemList'));
      otherwise
         mList=find_system('SearchDepth',1,...
            'BlockDiagramType','model');
         sList=excludesystems(z,...
            [mList;find_system(mList,...
               'Type','block',...
               'BlockType','SubSystem')]);
      end
   end
   
   if ~isempty(sList)
       switch sortBy
       case '$numBlocks'
           %calling with lower-case 'blocks' is important to
           %prevent special-case linking.
           blockList=propsystem(z,'GetPropValue',sList,'blocks');
           
           okEntries=find(cellfun('isclass',blockList,'cell'));
           blockList=blockList(okEntries);
           sList=sList(okEntries);
           
           blockList=cellfun('length',blockList);
           [blockList,sortIndex]=sort(blockList);
           sList=sList(sortIndex(end:-1:1));   
       case {'$alphabetical' '$systemalpha'}
           nameList=propsystem(z,'GetPropValue',sList,'name');
           
           okEntries=find(~cellfun('isempty',nameList));
           nameList=nameList(okEntries);
           sList=sList(okEntries);
           
           [nameList,nameIndex]=sort(lower(nameList));
           sList=sList(nameIndex);
       case '$depth'
           %calling with upper-case is important to force
           %the special-case property to happen
           depthList=propsystem(z,'GetPropValue',sList,'Depth');
           
           %Getting Depth returns [-1] if there was an error.
           
           depthList=[depthList{:}]';
           okEntries=find(depthList>=0);
           depthList=depthList(okEntries);
           sList=sList(okEntries);
           
           [depthList,depthIndex]=sort(depthList);
           sList=sList(depthIndex);
       otherwise
           %no sort
       end
       sList=sList(:);
   else
       sList={};
   end
end
