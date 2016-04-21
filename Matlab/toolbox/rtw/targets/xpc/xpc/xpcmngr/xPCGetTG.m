function tg=xPCGetTG(tree,varargin)
%XPCGETTG xpc Target Manager GUI
%   XPCGETTG Gets the target object from the Tree Node Menu

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision:

if (length(varargin)) 
   targetNameStr = varargin{1};    
elseif (findstr('TGPC',tree.SelectedItem.key))
   targetNameStr = strrep(tree.SelectedItem.Text,' ','');     
else
    fullpath=tree.SelectedItem.Fullpath;
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    tgNameStr=fullpath(1:sepIdx-1);
    targetNameStr=strrep(tgNameStr,' ','');
    allkeys=tree.GetAllKeys;
    tgxpcIdx=strmatch('TGPC',allkeys);           
end

AllTargets=tree.Targets;
evalstr=['AllTargets.',targetNameStr,'.tg;'];
tg=eval(evalstr);

