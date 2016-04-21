function tgEnv=xpcGetTarget(tree,varargin)
%XPCGETTARGET xPC Target GUI
%   XPCGETTARGET Gets the target Environment sturcture from the Tree

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

% Grab the env to create the Target Configurations and use for 
% default settings. 

%%%TO DO: Revise if needed to create default settings.

if length(varargin) > 1
   targetNameStr = varargin{1};    
elseif isempty(tree.SelectedItem)
    targetNameStr=tree.lastSelectedTarget;
elseif (findstr('TGPC',tree.SelectedItem.key))
   targetNameStr = strrep(tree.SelectedItem.Text,' ','');     
else
    fullpath=tree.SelectedItem.Fullpath;
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    tgNameStr=fullpath(1:sepIdx-1);
    tgNameStr=strrep(tgNameStr,' ','');
    targetNameStr=tgNameStr;
    allkeys=tree.GetAllKeys;
    tgxpcIdx=strmatch('TGPC',allkeys);           
end

targetpcMap=tree.TargetPCMap;
idxfound=strmatch(targetNameStr,targetpcMap(:,2),'exact');
treetgpcstr=targetpcMap{idxfound,1};

AllTargets=tree.Targets;
evalstr=['AllTargets.',treetgpcstr];
tgEnv=eval(evalstr);

