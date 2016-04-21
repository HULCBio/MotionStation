function t=verifychild(t)
%VERIFYCHILD makes sure child elements are valid

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:45 $

switch lower(t.tag)
case 'listitem'
   t=flatten(t,logical(0));
   okChildren={'Para' 'SimPara' 'Comment' 'Equation' 'Figure' ...
         'FormalPara' 'Graphic' 'ItemizedList' 'OrderedList' ...
         'SimpleList' 'Table'};
   t=LocVerify(t,okChildren,set(sgmltag,'Tag','Para'));   
case 'callout'
   t=flatten(t,logical(0));
   okChildren={'Anchor','BlockQuote','BridgeHead','CalloutList',...
         'Equation','Figure','FormalPara','GlossList','Graphic', ...
         'GraphicCO','InformalEquation','InformalExample','InformalTable', ...
         'ItemizedList','LiteralLayout','OrderedList','Para','ProgramListing',...
         'SegmentedList','SimPara','SimpleList','Table'};
   t=LocVerify(t,okChildren,set(sgmltag,'Tag','Para'));   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t=LocVerify(t,okChildren,wrapperTag)

childType={};

if iscell(t.data)
   oldData=t.data;
else
   oldData={t.data};
end

for i=length(oldData):-1:1
   if isa(oldData{i},'sgmltag')
      childType{i}=oldData{i}.tag;
   else
      childType{i}='PCDATA';
   end
end

validChildren=ismember(upper(childType),upper(okChildren));
newWrapper=logical(1);
newData={};
for i=1:length(validChildren)
   if validChildren(i)
      newData{end+1}=oldData{i};
      newWrapper=logical(1);
   else
      if newWrapper
         newData{end+1}=[wrapperTag;oldData{i}];
         newWrapper=logical(0);
      else
         newData{end}=[newData{end};oldData{i}];
      end
   end
end

t.data=newData;