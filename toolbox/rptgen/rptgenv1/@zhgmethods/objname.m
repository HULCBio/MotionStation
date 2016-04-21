function name=objname(z,h,okEmpty)
%OBJNAME returns the name of an HG object
%   NAME=OBJNAME(ZHGMETHODS,H)
%   NAME=OBJNAME(ZHGMETHODS,H,OKEMPTY)
%   
%   H is a handle graphics figure
%   OKEMPTY tells the function what to do if a suitable
%   object name can not be found.
%     1 = will return an empty name
%     0 = will return the handle in a string (default)
%    -1 = will return the object type and handle in a string
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:43 $

if nargin<3
   okEmpty=0;
end

if length(h)==1
   objType=get(h,'Type');
else
   objType='';
end

switch objType
case 'figure'
   nameChain={'Name' 'Tag' 'FileName'};
case 'axes'
   nameChain={'Title' 'XLabel' 'YLabel' 'ZLabel' 'Tag'};
case 'uicontrol'
   nameChain={'String' 'Style'};   
case 'uimenu'
   nameChain={'Label' 'Accelerator' 'Tag'};
case 'uicontextmenu'
   nameChain={'Tag'};   
case {'image' 'light' 'line' 'patch' 'surface'}
   nameChain={'Tag'};   
case 'text'
   nameChain={'String' 'Tag'};  
otherwise
   nameChain={};
end

name='';
i=1;
while isempty(name) & i<=length(nameChain)
   name=get(h,nameChain{i});
   if ~isempty(name)
      name=LocForceString(h,name);
   end
   i=i+1;
end

if isempty(name) & okEmpty<1
   if okEmpty<0
      typeName=objType;
   else
      typeName='';
   end
   name=[typeName ' ' num2str(h)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myStr=LocForceString(h,val)

switch class(val)
case 'char'
   myStr=strrep(singlelinetext(rptparent,val,' '),...
      sprintf('\n'),'');
case 'double'
   if ishandle(val) & h~=val
      myStr=objname(zhgmethods,val,logical(1));
   else
      myStr=num2str(val);
   end
case 'cell'
   if isempty(val)
      myStr='';
   else
      myStr=LocForceString(val{1,1});
   end
otherwise
   myStr='';
end
