function l=make_loop_comp(r,c)
%MAKE_LOOP_COMP creates a looping component
%   l=make_loop_comp(r,c) creates a loop component
%   of the type specified in c.att.ObjectType and
%   sets the component as a child of c.
%
%   Note that it returns a rptcp pointer.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:44 $

typeInfo=get_table(r,c);

strucName=sprintf('%sComponent',typeInfo.id);

loopComp=subsref(c,substruct('.','att','.',strucName));

if iscell(typeInfo.componentName)
   loopCompName = typeInfo.componentName{1};
   inputArgs=typeInfo.componentName(2:end);
else
   loopCompName = typeInfo.componentName;
   inputArgs={};
end

l=feval(loopCompName,loopComp);



set(l,'Parent',subsref(c,substruct('.','ref','.','ID','.','h')));

l=get(l,'UserData');

for i=1:2:length(inputArgs)-1
   l.att=setfield(l.att,inputArgs{i},inputArgs{i+1});   
end



