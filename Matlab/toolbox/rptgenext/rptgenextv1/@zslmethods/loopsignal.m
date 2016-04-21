function sigList=loopsignal(c,sortBy,signalScope,isIncoming,isOutgoing,isInternal)
%LOOPSIGNAL creates a list of signals upon which to loop
%   LIST=LOOPSIGNAL(C,'SortBy','ParentType')
%   SortBy can be 
%     $systemalpha
%     $alphabetical
%     $depth
%
%   ParentType represents the immediate loop under which the
%   signal list is being created.  ParentType is usually 
%   determined automatically using GETPARENTLOOP(C)
%     Model
%     System
%     Signal
%     Block
%
%   See also GETPARENTLOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:43 $

if nargin==1
   sigList.sortCode={
      '$alphabetical'
      '$alphabetical-exclude-empty'
      '$systemalpha'
      '$depth'
   };
   sigList.sortName={
      'Alphabetically by signal name'
      'Alphabetically by signal name (exclude empty)'
      'Alphabetically by system name'
      'By signal depth'
   };
   
   sigList.contextCode={
      'System'
      'Model'
      'Signal'
      'Block'
      ''
   };
   sigList.contextName={
      'All signals in current system'
      'Signals in current model'
      'Current signal'
      'Signals connected to current block'
      'All signals in all models'
   };
      
else
   
   z=zslmethods;
   
   switch signalScope
   case 'System'
      if nargin<6
         isInternal=logical(1);
         if nargin<5
            isOutgoing=logical(1);
            if nargin<4
               isIncoming=logical(1);
            end
         end
      end
      
      currSys=subsref(z,substruct('.','System'));
      
      if isInternal
         internalList=find_system(currSys,...
            'findall','on',...
            'SearchDepth',1,...
            'type','port',...
            'porttype','outport');
         
         if strcmp(get_param(currSys,'Type'),'block')
            sysPorts=get_param(currSys,'PortHandles');
            externalPorts=sysPorts.Outport(:);
         else
            externalPorts=[];
         end
         
         if isOutgoing & isIncoming
            badList=externalPorts;
         elseif isOutgoing
            badList=[externalPorts;...
                  LocPortSearch(z,currSys,'Inport')];
         elseif isIncoming
            badList=[externalPorts;...
                  LocPortSearch(z,currSys,'Outport')];
         else
            badList=[externalPorts;...
                  LocPortSearch(z,currSys,'Outport');...
                  LocPortSearch(z,currSys,'Inport')];
         end
         sigList=setdiff(internalList,badList);
         sigList=sigList(:);
      else
         if isOutgoing
            outList=LocPortSearch(z,currSys,'Outport');
         else
            outList=[];
         end
         if isIncoming
            inList=LocPortSearch(z,currSys,'Inport');
         else
            inList=[];
         end
         sigList=[outList;inList];
      end
   case 'Signal'
      sigList=subsref(z,substruct('.','Signal'));
   case 'Block'
      if nargin<5
         isOutgoing=logical(1);
         if nargin<4
            isIncoming=logical(1);
         end
      end
      

      currBlk=subsref(z,substruct('.','Block'));
      if ~isempty(currBlk)
         try
            allPorts=get_param(currBlk,'PortHandles');
         catch
            allPorts=struct('Outport',[],'Inport',[]);
         end
         
         if isOutgoing
            sigList=allPorts.Outport(:);
         else
            sigList=[];
         end
         
         if isIncoming
            sigList=[sigList;LocInport2Outport(z,allPorts.Inport)];
         end
      else
         sigList=[];
      end
   case 'Model'
      sigList=subsref(z,substruct('.','ReportedSignalList'));
   otherwise %if we are not inside a model loop
      mList=find_system('SearchDepth',1,...
         'BlockDiagramType','model');
      
      sigList=find_system(mList,...
         'findall','on',...
         'type','port',...
         'porttype','outport');
   end
   
   if length(sigList)>1
      switch sortBy
      case '$systemalpha'
         blkList=getparam(z,sigList,'Parent');
         sysList=getparam(z,blkList,'Parent');
         [sysList,sysIndex]=sort(lower(sysList));
         sigList=sigList(sysIndex);
      case '$alphabetical-exclude-empty'
         nameList=getparam(z,sigList,'Name');
         emptyIndex=find(cellfun('isempty',nameList));
         spaceIndex=find(strcmp(nameList,'&nbsp;'));
         okIndex=setdiff([1:length(nameList)],[emptyIndex spaceIndex]);
         nameList=nameList(okIndex);
         sigList=sigList(okIndex);
         [nameList,nameIndex]=sort(lower(nameList));
         sigList=sigList(nameIndex);
      case '$alphabetical'
         nameList=getparam(z,sigList,'Name');
         [nameList,nameIndex]=sort(lower(nameList));
         sigList=sigList(nameIndex);
      case '$depth'
         %calling with upper-case is important to force
         %the special-case property to happen
         depthList=propsignal(z,'GetPropValue',sigList,'Depth');
         %protecting against empty cells in depthList
         emptyDepth=find(cellfun('isempty',depthList));
         if length(emptyDepth)>0
            [depthList{emptyDepth}]=deal(0);
         end      
         [depthList,depthIndex]=sort([depthList{:}]);
         
         sigList=sigList(depthIndex);   
      end
   elseif length(sigList)==1
      switch sortBy
      case '$alphabetical-exclude-empty'
         nameList=getparam(z,sigList,'Name');
         if isempty(nameList{1})
            sigList=[];
         end
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outP=LocInport2Outport(z,inP)

inLine=getparam(z,inP,'Line');
lineHandleList=[inLine{:}];
lineSource=getparam(z,lineHandleList,'srcporthandle');

outP=[lineSource{:}];
outP=outP(:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pList=LocPortSearch(z,currSys,blkType);

blkList=find_system(currSys,...
   'SearchDepth',1,...
   'BlockType',blkType);

pList=[];

isOutport=strcmp(blkType,'Outport');

for i=1:length(blkList)
   try
      blkPorts=get_param(blkList{i},'PortHandles');
   catch
      allPorts=struct('Outport',[],'Inport',[]);
   end
   if isOutport
      pList=[pList;LocInport2Outport(z,blkPorts.Inport)];
   else
      pList=[pList;blkPorts.Outport(:)];
   end
end
