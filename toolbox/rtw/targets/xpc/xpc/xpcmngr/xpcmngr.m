function subhandle=xpcmngr(varargin)
%XPCMNGR xPC Target GUI
%   XPCMNGR manages the xpcmngr GUI and the target from the xPC Target Manager GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

if isempty(varargin)    
    feature('Javafigures',0)
    xpcmngrGUI('InitGUI')
%     warning off MATLAB:dispatcher:InexactMatch
%     warning off MATLAB:dispatcher:InexactMatch
    feature('Javafigures',1)

    return  
end

if strcmpi(varargin{1},'JavaFigures')
    feature('Javafigures',1)
	xpcmngrGUI('InitGUI')
    return  
end

Action = varargin{1};
args   = varargin(2:end);

switch Action,

case 'AddTarget'
    subhandle=@xpc_savexPCEnv;
    return    
case 'Download2Target'
    subhandle=@xpc_downloaddlm2tg;
    return
case 'ConnectTargetPC'
    subhandle=@xpc_ConnectTarget;
    return    
case 'DisconnectTargetPC'
    subhandle=@xpc_DisConnectTarget;
    return    
case 'UnloadApp'
     subhandle=@xpc_unload_tg;
    return    
case 'AddxPCScope'   
    subhandle=@xpc_AddScope;
    return
case 'StartScopeid'    
    subhandle=@xpc_startScid;
    return
case 'StopScopeid'    
    subhandle=@xpc_stopScid;
    return
case 'RemoveScopeid'
    subhandle=@xpc_RemoveScope;
    return
case 'AddSigId2ScId'
    subhandle=@xpc_AddSignal2Scope;
    return
case 'RemSigIdfromScId'
    subhandle=@xpc_remSignalFromScope;    
    return
otherwise,
    error(['Invalid action: ' Action]);
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   XPC Communication functions                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpc_downloaddlm2tg(tg,dlmName)
dlmName=dlmName(1:end-4);
tg.load(dlmName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  xpc_unload_tg(tg)
tg.unload;
%xPCtargetPC.tg.unload
%xPCtargetPC.tg=[];
%tg=xpc;
%tg.unload;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  xpc_start_tg(tg)
+tg;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  xpc_stop_tg(tg)
-tg
%xPCtargetPC.tg.unload
%xPCtargetPC.tg=[];
%tg=xpc;
%tg.unload;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [scopeid]=xpc_AddScope(tg,tree,ScopeType)

if ~(nargin == 3)
    if findstr('HostSc',tree.SelectedItem.Key)
        ScopeType='Host';
    elseif findstr('TgSc',tree.SelectedItem.Key)
        ScopeType='Target';    
    elseif findstr('FileSc',tree.SelectedItem.Key)
        ScopeType='File';
    end
end

    
sc=tg.addscope(ScopeType);
scopeid=sc.ScopeId;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpc_RemoveScope(tg,scopeid)
tg.remscope(scopeid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  xpc_startScid(tg,scopeid,tree)
sc=tg.getscope(scopeid);
start(sc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  xpc_stopScid(tg,scopeid,tree)
sc=tg.getscope(scopeid);
stop(sc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tg = xpc_ConnectTarget(xPCEnv,tree)
commType=xPCEnv.HostTargetComm;
if strcmp(commType,'TcpIp')
   arg1= 'TcpIp';
   arg2= xPCEnv.TcpIpTargetAddress;
   arg3= xPCEnv.TcpIpTargetPort;
  % arg3= xPCtargetPC.xPCtargetPC;
else%rs232
   arg1= 'RS232';
   arg2= xPCEnv.RS232HostPort;
   arg3= eval(xPCEnv.RS232Baudrate);
end    
try
    conStatus=xpctargetping(arg1,arg2,arg3);
catch
    tg=[];
    errordlg(lasterr,'xPC Target Error');
    return
end
if strcmp(conStatus,'failed')
    tg=[];
    errordlg('Communication Error. Please check Communication settings','xPC Target Error')    
    return
end
tg=xpc(arg1,arg2,arg3);

targetpcMap=tree.TargetPCMap;
tgNameStr=tree.SelectedItem.Text;
idxfound=strmatch(tgNameStr,targetpcMap(:,2),'exact');
tgpcstr=targetpcMap{idxfound,1};

%%To do revost if I ping the Target here
if strcmpi(tg.Connected,'Yes')    
%    evalstr=['tree.Targets.',tgpcstr,'.tg=tg;'];
%    eval(evalstr);
    if ~strcmp(tg.application,'loader')
        try
            bio=eval([tg.Application,'bio;']);
            pt=eval([tg.Application,'pt;']);
        catch
            tg=[];
            errordlg('Unable to load. Generated application files are missing','xPC Target Error'  )
            return
        end
        evalstr=['tree.Targets.',tgpcstr,'.bio=bio;'];
        eval(evalstr);
        evalstr=['tree.Targets.',tgpcstr,'.pt=pt;'];
        eval(evalstr);
    end
    
    %tree.Targets.TargetPC1.tg=tg;
    %tree.SelectedItem.Image=3;
end
evalstr=['set(tree,','''',tgpcstr,'''',',tg)'];
eval(evalstr);
xpcmngrUserData=get(tree.figHandle,'UserData');
if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
   list=xpcmngrUserData.listCtrl;
    if ~isempty(tg) 
        if strcmp(tg.application,'loader')
            set(list.ListItems.Item(1).listsubItems.Item(1),'Text','loader')
            set(list.ListItems.Item(9).listsubItems.Item(1),'Text','Yes')
        else
            set(list.ListItems.Item(1).listsubItems.Item(1),'Text',tg.application)
            set(list.ListItems.Item(2).listsubItems.Item(1),'Text',tg.Mode)
            set(list.ListItems.Item(3).listsubItems.Item(1),'Text',getlogstatus(tg))
            set(list.ListItems.Item(4).listsubItems.Item(1),'Text',sprintf('%0.4f',tg.StopTime))
            set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.SampleTime))
            set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.AvgTeT))
            set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%0.4f',tg.ExecTime))    
            set(list.ListItems.Item(9).listsubItems.Item(1),'Text','Yes')
        end
    else
        set(list.ListItems.Item(8).listsubItems.Item(1),'Text',xpcmngrUserData.treeCtrl.selectedItem.Text)
        set(list.ListItems.Item(9).listsubItems.Item(1),'Text','No')
    end    
end
%tg=xpc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpc_DisConnectTarget(tree,tg,tgName)
if (nargin == 2)
    tgName=tree.selectedItem.Text;
end
%targets=tree.targets;
targetpcMap=tree.TargetPCMap;
idxfound=strmatch(tgName,targetpcMap(:,2),'exact');
tgpcstr=targetpcMap{idxfound,1};
%tg must be already closed from a delete(tg) call

if isa(tg,'xpctarget.xpc')
    tg.close;
end

set(tree,tgpcstr,[])
%eval(['targets.',tgpcstr,'.tg = [];'])
%tree.targets=targets;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigcheck=xpc_AddSignal2Scope(tg,sigName,scopeId)
xpcsigIdx=tg.getsignalid(sigName);
%sc=tg.getscope;
sigonscope=xpcgate(tg.port,'getscsignals',scopeId);
if ismember(xpcsigIdx,sigonscope)%if already exits do nothing
    sigcheck=0;
else    
    xpcgate(tg.port,'addsig',scopeId,xpcsigIdx);
    sigcheck=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scType=xpc_remSignalFromScope(tg,sigName,scopeid);
sc=tg.getscope(scopeid);
sc.remsignal(tg.getsignalid(sigName));
scType=sc.Type;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logstrst=getlogstatus(tg)
status=xpcgate(tg.port,'getlogstatus');
logstatusstr={'Off','Acquiring'};
if status(1) %if logging is turned on
    logtimecellstr={'','t '};logstatecellstr={'','x '};
    logopcellstr={'','y '};logtetcellstr={'','tet'};
    logstrst=[logtimecellstr{status(2)+1},logstatecellstr{status(3)+1}, ...
              logopcellstr{status(4)+1}, logtetcellstr{status(5)+1}];
else
logstrst = 'Off';
end


% function xPCEnv=xpc_savexPCEnv(tree)
% %%Save xpctgEnv in Tree
% env=getxpcenv;
% S=cell2struct(env.actpropval,env.propname,2);
% tgs=tree.Targets;
% S.tg=[];
% if isempty(tgs)
%    tgStruct=[]; 
%    tree.Targets=tgStruct;
% end
% tgpcNodes=length(strmatch('TGPC',tree.GetAllKeys));
% %ne=tree.nodes.Add(1,4);
% ne=tree.nodes.Add;
% ne.Text=['Target PC',sprintf('%d',tgpcNodes+1)];
% ne.Key=['TGPC',sprintf('%d',ne.Index)];
% ne.Image=18;
% str=['tree.Targets.',strrep(ne.Text,' ',''),'= S;'];
% eval(str);
% %tree.addproperty(['TargetPC',sprintf('%d',tgpcNodes+1)]);
% %Add Target Configuretion Node
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
