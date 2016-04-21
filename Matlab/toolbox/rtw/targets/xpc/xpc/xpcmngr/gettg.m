function tg=gettg(tree,varargin)
%GETTG xPC Target GUI
%   GETTG Returns the xPC Target Object from the Selected Tree Node.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $

if (length(varargin)) 
   targetNameStr = varargin{1};    
elseif (findstr('TGPC',tree.SelectedItem.key))
   targetNameStr = tree.SelectedItem.Text;
else
    fullpath=tree.SelectedItem.Fullpath;
    if findstr(fullpath,'Host PC')
        tg=[];
        return
    end
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    targetNameStr=fullpath(1:sepIdx-1);
    %allkeys=tree.GetAllKeys;    
end

targetpcMap=tree.TargetPCMap;
idxfound=strmatch(targetNameStr,targetpcMap(:,2),'exact');
treetgpcstr=targetpcMap{idxfound,1};

evalstr=['get(tree,','''',treetgpcstr,'''',');'];
try
    tg=eval(evalstr);
catch
    tg=[];
    return
end
% if ~isempty(tg)
%     if ~isa(tg,'xpctarget.xpc')       
%        xpcmngrUserData=get(tree.FigHandle,'UserData'); 
%        xpcmngrUserData.timerObj.enabled=0;
%        
%        feval(xpcmngr('DisconnectTargetPC'),tree,tg,targetNameStr)  
%        feval(xpcmngrTree('Disconnect'),tree) 
%        tg=[];
%        if (xpcmngrUserData.timerObj.enabled == 0)
%            xpcmngrUserData.timerObj.enabled=1;
%        end
%     end
% end
