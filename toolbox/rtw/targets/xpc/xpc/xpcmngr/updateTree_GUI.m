function updateTree_GUI(tree)
%%%%Update on Node Click

% Copyright 2003 The MathWorks, Inc.

xpcmngrUserData=get(tree.figHandle,'Userdata');
fullpath=tree.SelectedItem.Fullpath;
if findstr('TGPC',tree.SelectedItem.Key)
    tgNameStr=tree.SelectedItem.Text;    
elseif findstr('Host PC',fullpath)
    set(tree.Nodes.Item(1),'Bold',1);
    tgNameStr='Host PC';
    feval(xpcmngrUserData.drawPanelapi.menufcn,...
           xpcmngrUserData.figure,'Target','on');
else
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    tgNameStr=fullpath(1:sepIdx-1);
end
allNames=tree.GetAllNames;
allkeys=tree.GetAllKeys;
alltgxpcIdx=strmatch('TGPC',allkeys); 
tgxpcIdx=strmatch(tgNameStr,allNames); 
remtgxpc=setxor(tgxpcIdx,alltgxpcIdx);
set(tree.Nodes.Item(tgxpcIdx),'Bold',1);

for ij=1:length(remtgxpc)    
    set(tree.Nodes.Item(remtgxpc(ij)),'Bold',0);
    %set(tree.Nodes.Item(1),'Bold',0);
end

%tg=gettg(tree);

%       feval(xpcmngrUserData.drawPanelapi.menufcn,...
%           xpcmngrUserData.figure,'Target','on');
