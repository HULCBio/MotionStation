function mcoderegister(param1,h, param2,hTarget, param3,fname)
%MCODEREGISTER For registering plots with m-code generation
%
%   MCODEREGISTER('Handles',h,'Target',hTarget,'Name','myfunction')

% Copyright 2003-2004 The MathWorks, Inc.

% Register handles with mcode generator 
hBehavior = hgbehaviorfactory('MCodeGeneration');
set(hBehavior,'MCodeIgnoreHandleFcn',{@localMCodeIgnoreHandle,hTarget});
set(hBehavior,'MCodeConstructorFcn',{@localMCodeConstructor,fname});
hgaddbehavior(h,hBehavior);

%--------------------------------------------------------%
function localMCodeConstructor(hObj,hCode,fname)

hFunc = getConstructor(hCode);
str = sprintf('%%%% %s(...)',fname);
comment = sprintf('%s does not support code generation, type ''doc %s'' for correct input syntax',fname,fname);
set(hFunc,'Comment',comment);
set(hFunc,'Name',str);

%--------------------------------------------------------%
function bool = localMCodeIgnoreHandle(hParent,hKid,hTarget)

bool = true;
if ishandle(hTarget) && isequal(handle(hKid),handle(hTarget))
    bool = false;
end

