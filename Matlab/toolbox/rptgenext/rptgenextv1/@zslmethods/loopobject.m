function out=loopobject(c,objType,objList)
%LOOPOBJECT loop over objects
%    CONTENT=LOOPOBJECT(C,OBJTYPE,OBJLIST) loops over the
%    objects specified in OBJLIST.
%    If OBJTYPE is 'Model', OBJLIST is a structure of the
%       type returned by LOOPMODEL.
%    If OBJTYPE is 'System', OBJLIST is a cell array of the
%       type returned by LOOPSYSTEM
%    If OBJTYPE is 'Block', OBJLIST is a cell array of the
%       type returned by LOOPBLOCK
%    If OBJTYPE is 'Signal', OBJLIST is a vector of the
%       type returned by LOOPSIGNAL
%
%    See also LOOPMODEL, LOOPSYSTEM, LOOPBLOCK, LOOPSIGNAL

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:42 $


if isempty(objList)
   status(c,sprintf('Warning - no %ss found for looping.',objType),2);
   out='';
   return
end

myChildren=children(c);
if isempty(myChildren)
   out='';
   status(c,sprintf('Warning - %s Loop has no subcomponents',objType),2);
   return;
else
   out={};
end

z=subsref(c,substruct('.','zslmethods'));
r=subsref(c,substruct('.','rptcomponent'));

%if nargin<4
%   isLinkAnchor=logical(0);
%end
%if isLinkAnchor
%   linkObj=r.comps.cfrlink;
%   
%   linkObj.att.LinkType='Anchor';
%   linkObj.att.LinkText='';
%end

prevObj=subsref(z,substruct('.',objType));

if strcmp(objType,'Model')
   modelHelperList=FindHelperObjects('rpt_event_newmodel.m');
end

for i=1:length(objList)
   %Check to see if the "stop" button has been clicked
   if r.HaltGenerate
      status(c,[objType ' Loop execution halted'],2);
      break
   end
   
   %Check to see if the looped object exists and get its name
   objName='';
   switch objType
   case 'Model'
      objName=objList(i).MdlName;
      currObj=objList(i).MdlName;
      try
         open_system(currObj);
         ok=strcmp(get_param(currObj,'Type'),'block_diagram');
      catch
         ok=0;
      end
   case 'System'
      currObj=objList{i};
      try
         objName=get_param(currObj,'Name');
         ok=strcmp(get_param(currObj,'Type'),'block');
         if ok
            ok=strcmp(get_param(currObj,'BlockType'),'SubSystem');
         else
            ok=strcmp(get_param(currObj,'Type'),'block_diagram');
         end
         
      catch
         objName=objList{i};
         ok=logical(0);
      end
      
   case 'Block'
      currObj=objList{i};
      try
         objName=get_param(currObj,'Name');
         ok=strcmp(get_param(currObj,'Type'),'block');
      catch
         objName=objList{i};
         ok=logical(0);
      end
      
   case 'Signal'
      currObj=objList(i);
      try
         objName=get_param(currObj,'Name');
         ok=strcmp(get_param(currObj,'Type'),'port');
      catch
         objName='';
         ok=logical(0);
      end
      if isempty(objName)
         objName=objList(i);
      end
   end
   
   if ischar(objName)
      objName=strrep(objName,sprintf('\n'),' ');
   elseif isnumeric(objName)
      objName=sprintf('%f',objName);
   else
      objName='<name not found>';
   end
   
   if ok
      status(c,sprintf('Looping on %s "%s".',objType,objName),3);
      
      %if isLinkAnchor
      %   linkObj.att.LinkID=linkid(z,currObj,objType);
      %   out{end+1}=runcomponent(linkObj,0);
      %end
      
      %Set the ZSLMETHODS data structure so that the current
      %objects are the ones being looped on
      switch objType
      case 'Model'
         try
            set_param(0,'CurrentSystem',currObj);
         end
         
         for j=1:length(modelHelperList)
            try
               ok=rpt_event_newmodel(modelHelperList{j},objList(i));
            catch
               ok=logical(0);
            end
            if ~ok
               status(c,sprintf(...
			      'Warning - New model event method for object "%s" did not execute properly',...
                  class(modelHelperList{j})),...
                  2);
            end
         end
         
      case 'System'
         try
            set_param(0,'CurrentSystem',currObj);
         end
         
         d=rgstoredata(z);      
         d.System=currObj;
         d.Block=[];
         d.Signal=[];
         rgstoredata(z,d);
      case 'Block'
         d=rgstoredata(z);      
         d.Block=currObj;
         d.Signal=[];
         rgstoredata(z,d);
      case 'Signal'
         d=rgstoredata(z);      
         d.Signal=currObj;
         d.Block=[];
         rgstoredata(z,d);
      end
      
      %Run the subcomponents
      out{end+1}=runcomponent(myChildren);
   else
      status(c,sprintf('Warning - Can not find %s "%s".',objType,objName),2);
   end
end

subsasgn(z,substruct('.',objType),prevObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objList=FindHelperObjects(methodName)

methodList=which(methodName,'-all');
objList={};

for i=length(methodList):-1:1
   sepLoc=findstr(methodList{i},filesep);
   if length(sepLoc)>1
      objName=methodList{i}(sepLoc(end-1)+1:sepLoc(end)-1);
      if length(objName)>1 & ...
            abs(objName(1))==abs('@')
         try
            objList{end+1,1}=eval(objName(2:end));
         end
      end
   end
end