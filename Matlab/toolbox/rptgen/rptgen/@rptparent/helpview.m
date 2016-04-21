function errMsg=helpview(obj,topic,type,varargin)
%HELPVIEW launch the help viewer for the report generator
%   HELPVIEW(P,'csl_sys_loop','component')
%        Call the help viewer for a component
%   HELPVIEW(P,'SL','category');
%        Call the help viewer for a component category type
%   HELPVIEW(P,'SL','category',ALLTYPES,ALLCOMPS);
%        A faster 
%   HELPVIEW(P,'Topic');
%        Call the help viewer for a mapped topic

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:17 $

if isa(obj,'rptcomponent')
   topic=class(obj);
   type='component';
elseif nargin<3
   type='component';
   if nargin<2
      topic='coutline';
   end
elseif strcmp(type,'category')
   if length(varargin)<1
      allTypes=[];
   else
      allTypes=varargin{1};
      if length(varargin)<2
         allComps=[];
      else
         allComps=varargin{2};
      end
   end
end
topic=lower(topic);

dR=docroot;
if isempty(dR)
   dR=fullfile(matlabroot,'help');
end


mapfileName=fullfile(dR,['mapfiles' filesep 'rptgenv1.map']);

switch type
case 'category'
   prefixStr='comp_category_';
case 'component'
   prefixStr='comp_ref_';
case 'product'
   prefixStr='product_';
otherwise
   prefixStr='';
end

try
   oldWarn=nenw(obj);
   helpview(mapfileName,[prefixStr topic]);
   nenw(obj,oldWarn);
   errMsg='';
catch
   errMsg=lasterr;
   switch type
   case 'category'
      helpwin(LocCategoryStr(obj,topic,allTypes,allComps),...
         'Report Generator Help');
   case {'component' 'product'}
      helpwin(topic);
   end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function helpStr=LocCategoryStr(p,topic,allTypes,allComps)

if isempty(allComps)
   allComps=allcomps(p);
end

if isempty(allTypes)
   allComps=allcomptypes(p);
end

typeIndex=find(strcmpi({allTypes.Type},topic));
if length(typeIndex)>0
   typeIndex=typeIndex(1);
   
   compTypeName=allTypes(typeIndex).Fullname;
   
   helpStr={sprintf('All %s Components',compTypeName);''};
   
   matchingTypes=find(strcmpi({allComps.Type},topic));
   helpCells=cell(0,3);
   for i=1:length(matchingTypes)
      cClass=allComps(matchingTypes(i)).Class;
      eval(['newcomp=',cClass,';'],'newcomp=[];')
      if isa(newcomp,'rptcp')
         i=getinfo(newcomp);
         delete(newcomp);
         helpCells(end+1,1:3)={cClass,i.Name,i.Desc};            
      end
   end
   
   hSize=size(helpCells);
   if hSize(1)>0
      helpCells=[{'Class','Name','Description'};helpCells];
      colLength=max(cellfun('length',helpCells),[],1);
      for i=1:hSize(1)+1
         classStr=helpCells{i,1};
         pad1=blanks(colLength(1)-length(classStr)+1);
         nameStr=helpCells{i,2};
         pad2=blanks(colLength(2)-length(nameStr)+3);
         descStr=helpCells{i,3};
         if i>1
            midStr='- ';
         else
            midStr='  ';
         end
         
         helpStr{end+1,1}=[classStr pad1 midStr nameStr pad2 descStr];
      end
   else
      helpStr{end+1,1}='Warning - no components matching type found';       
   end   
else
   helpStr={sprintf('Warning - component type "%s" not found',topic)};      
end