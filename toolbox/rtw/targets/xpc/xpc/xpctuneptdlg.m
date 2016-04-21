function xpctuneptdlg(blockinfo,flag2,xpcparam,Hfig)
% XPCTUNEPTDLG xPC Target tunabale parameters Dialog prompt.
%
%   This function should not be called directly.
%
%   See Also XPCRCTOOL, XPCSIMVIEW.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.14.6.1 $ $Date: 2004/04/08 21:05:20 $

if checkForFeature
  if blockinfo.isSrc
    if ~isappdata(0, 'xPCTargetSourceBlocksOpen') || ...
          isempty(getappdata(0,'xPCTargetSourceBlocksOpen'))
      setappdata(0, 'xPCTargetSourceBlocksOpen', 1);
    else
      setappdata(0, 'xPCTargetSourceBlocksOpen', ...
                    getappdata(0, 'xPCTargetSourceBlocksOpen') + 1);
    end
  end
end

blockname= blockinfo.BlockName;
blockname(find(blockname==10))=32;
blocktype= blockinfo.BlockType;
blocktype(find(blocktype==10))=32;
dialog=blockinfo.Dialog;
if isempty(dialog)
  return
end

if strcmp(blockinfo.BlockType,'S-Function')
  return
end
fnames=fieldnames(dialog);
blkname=xpcparam.blockname;
parname=xpcparam.paramname;
paridx= strmatch(blockname,blkname,'exact');
fnames=parname(paridx);
numoftunablept=length(parname(paridx));
figcolor=get(0,'DefaultFigureColor');
figheight=numoftunablept*5+3;

if (numoftunablept==1)
  figheight=10;
end
if (isempty(strmatch(blockname,blkname,'exact')) )
  return
end

mousepos=getMousePos;
defcolor=get(0,'defaultuicontrolbackgroundcolor');
figh=figure('MenuBar','none',...
            'NumberTitle','off',...
            'Units','characters',...
            'HandleVisibility','callback',...
            'position',[mousepos(1)   mousepos(2)-(figheight/2) ...
                    79.2000       figheight],...
            'Color',defcolor,...
            'Name',['Block Parameters: ',blocktype],...
            'Resize','off',...
            'Tag','xPCTunedlg',...
            'IntegerHandle', 'off', ...
            'CloseRequestFcn',@closedlgfig,...
            'visible','on');
setappdata(figh,'viewer',Hfig);
refpos=get(figh,'Position');
%ind=findstr(blockname,'/');
%sysn=blockname(1:ind(1)-1);
huifr=uicontrol(figh,'style','frame','units','characters',...
                'position',[1,3,76.7,figheight-4.0],...
                'Foregroundcolor',[0 0 0],...
                'backgroundcolor',defcolor,'tooltipstring',...
                ['Block name: ',blockname]);
huitextParameter=uicontrol(figh,'style','text','units','characters',...
                           'position',[3.8,figheight-2.0,20.0,1.4615384615384617],...
                           'string','Tunable Parameters:','HorizontalAlignment','Left');
%refpointpos=[3.2,11.0,14.8,1.4615384615384617]
refpointpos=[3.2,figheight-2,14.8,1.4615384615384617];

for i=1:length(fnames)
  dfield= getfield(dialog,fnames{i});
  if ~(isempty(strmatch(blockname,blkname,'exact')) | isempty(strmatch(fnames{i},parname,'exact')) )
    h=uicontrol(figh,'style','text','units','characters',...
                'position',[3.8,refpointpos(2)-1.0,50,1.07],...
                'string',dfield.Prompt,'HorizontalAlignment','Left');
    if strcmp(dfield.Type,'string')
      h=uicontrol(figh,'style','edit','units','characters',...
                  'position',[3.8,refpointpos(2)-2.9,72.4,1.5],...
                  'string','','HorizontalAlignment','Left',...
                  'BackgroundColor',[1,1,1]);
    elseif strcmp(dfield.Type,'enum')
      h=uicontrol(figh,'style','popup','Units','characters',...
                  'position',[3.8,refpointpos(2)-3-1,72.4,2],...
                  'HorizontalAlignment','left','BackgroundColor',...
                  [1,1,1],'String',dfield.Enum);
    elseif strcmp(dfield.Type,'boolean')
      h=uicontrol(figh,'style','checkbox','Units','characters',...
                  'position',[3.8,refpointpos(2)-3-1,72.4,2],...
                  'value',0,'HorizontalAlignment','left');
    end  %strcmp(dfield.Type,'string')
    usrdataETCB={blockname,fnames{i},h};
    data(i).blockname=blockname;
    data(i).fname=fnames{i};
    data(i).handles=h;
    if (flag2 == 1)
      try
        sysName=xpcgate('getname');
        paramid = xpcgate('getparid', blockname, fnames{i},sysName);
        paramid=str2num(paramid(2:end));
        if ~isempty(paramid)
          parstrval=xpcgate('getpar', paramid);
          [m1,n1]=size(parstrval);
          parstrval=reshape(parstrval,1,prod(size(parstrval)));
          [m,n]=size(parstrval);
          data(i).size=[m1 n1];
          if (find(data(i).size==1))
            set(h,'tooltipstring',['Vector(',num2str(m1),' x ',num2str(n1),')']);
          else
            set(h,'tooltipstring',['Matrix(',num2str(m1),' x ',num2str(n1),')']);
          end
          if (length(parstrval)==1) %scaler
            data(i).paramValue=parstrval;
            set(h,'string',['[',num2str(parstrval),']']);
          end
          if (length(parstrval)>1)%vector
            datapt=parstrval(1:end);
            data(i).paramValue=datapt;
            set(h,'string',['[',num2str(datapt),']']);
          end
        end
      catch
        error(xpcgate('xpcerrorhandler'));
      end
    end %(flag2 == 1)
    refpointpos=[3.8,refpointpos(2)-4,72.4,2];

  end %~(isempty(strmatch(blockname,blkname,'exact'))........
  usrdata=data;
  set(h,'Userdata',usrdata,'callback',@setxpcparam);
end % i=1:length(fnames)

usrdata=data;
isSrc = checkForFeature && blockinfo.isSrc;

if ~isSrc
  happly = uicontrol(figh,                                 ...
                     'style',               'pushbutton',  ...
                     'units',               'characters',  ...
                     'position',            [58,0.5,20,2], ...
                     'string',              'Apply',       ...
                     'HorizontalAlignment', 'left',        ...
                     'callback',            @setxpcparam,  ...
                     'Tag',                 'PressApply',  ...
                     'UserData',            usrdata);
end
setappdata(figh, 'isSrc', isSrc);

hok    = uicontrol(figh, 'style',               'pushbutton',  ...
                   'Units',               'characters',  ...
                   'position',            [1,0.5,20,2],  ...
                   'string',              'OK',          ...
                   'HorizontalAlignment', 'left',        ...
                   'callback',            @setxpcparam,  ...
                   'Tag',                 'PressOk',     ...
                   'UserData',            usrdata);

hcl    = uicontrol(figh, 'style',               'pushbutton',  ...
                   'Units',               'characters',  ...
                   'position',            [30,0.5,20,2], ...
                   'string',              'Cancel',      ...
                   'HorizontalAlignment', 'left',        ...
                   'callback',            'close(gcbf)');
%set(figh,'KeyPressFcn',@setxpcparam)
% ----------------------------------------

function setxpcparam(h,eventdata)

if strcmp('xPCTunedlg',get(h,'Tag'))
  usrdata=get(findobj(get(h,'children'),'tag','PressOk'),'UserData');
  closeH=h;
  flag=1;
elseif strcmp('PressOk',get(h,'Tag'))
  usrdata=get(h,'UserData');
  closeH=get(h,'parent');
  flag=1;
elseif strcmp('PressApply',get(h,'Tag'))
  usrdata=get(h,'UserData');
  closeH=get(h,'parent');
  flag=0;
elseif strcmpi('edit',get(h,'Style'))
  usrdata=get(h,'Userdata');
  flag=0;
end
parhandles=cat(1,usrdata.handles);
for j=1:length(usrdata)
  oldparvals=cat(1,usrdata(j).paramValue);
  % newparvals=str2num(char(get(parhandles(j),'string')));
  strval=get(parhandles(j),'string');
  evalexp=['[',strval,']'];
  try
    newparvals=eval(evalexp);
  catch
    errordlg(lasterr);
    return
  end
  if~(isequal(size(newparvals),size(oldparvals)))
    errordlg('Parameter size mismatch. Can not change the dimension of parameters','xPC Target error');
    return
  end

  usrdata(j).paramValue= newparvals;
  set(h,'userdata',usrdata)
  sizemn=usrdata(j).size;
  m=sizemn(1);n=sizemn(2);
  isident=isidentical(oldparvals,newparvals);
  if ~isident
    blockpath=usrdata(j).blockname;
    paramname=usrdata(j).fname;
    paramValue=newparvals;
    try
     % paramid = xpcgate('getparid', blockpath, paramname);
      paramid=xpcgate('getparindex',blockpath, paramname);
      paramid=str2num(paramid(2:end));
      if ~isempty(paramid)
        xpcgate('setpar',paramid, reshape(paramValue,m,n));
      end
    catch
      error(xpcgate('xpcerrorhandler'),'xPC Target error');
      return;
    end
  end
end

if (flag)
  figure(getappdata(closeH,'viewer'))
  close(closeH);
end

% ----------------------------------------
function mspos=getMousePos
hidhstat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
figH = findobj('Type','Figure','Tag','SL2XMLFigure');
set(0,'showhiddenhandles',hidhstat)
defunit=get(0,'units');
set(0,'Units','characters');
mspos=get(0,'PointerLocation');
set(figH,'Units','Pixels');
set(0,'Units',defunit)
% ----------------------------------------
function closedlgfig(h,eventdata)
if isequal(getappdata(h, 'isSrc'), 1)
  srcBlks = getappdata(0, 'xPCTargetSourceBlocksOpen');
  setappdata(0, 'xPCTargetSourceBlocksOpen', max([0,srcBlks - 1]));
end

if (h)
  figure(getappdata(h,'viewer'))
  delete(h);
end