function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page
%   C=ATTRIBUTE(C,'Action',argin1,argin2,...)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:28 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

c=controlsmake(c);

set([c.x.EvalStringTitle],...
   'HorizontalAlignment','left');
set([c.x.EvalString c.x.CatchString],...
   'FontName',get(0,'fixedwidthfont'));

c.x.EvalNow=uicontrol(c.x.all,...
   'Style','pushbutton',...
   'String','Eval Now',...
   'ToolTipString','',...
   'Callback',[c.x.getobj,'''EvalNow'');']);

set(c.x.CatchString,'Enable',LocOnOff(c.att.isCatch));

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

pad=5;
barht=layoutbarht(c);
barwidth=c.x.xext-c.x.xzero-2*pad;
leftoverHt=(c.x.ylim-c.x.yorig-4*barht-5*pad);
editht1=leftoverHt*.75;
editht2=leftoverHt*.25;

evext=get(c.x.EvalNow,'Extent');
evalBtnWid=min(evext(3)+pad,barwidth*.3);

pos=[c.x.xzero+pad c.x.ylim-barht-pad barwidth barht];
set(c.x.isInsertString,'Position',pos);

pos(2)=pos(2)-barht;
set(c.x.isDiary,'Position',pos);

pos=[c.x.xzero+pad pos(2)-1.5*barht barwidth-evalBtnWid barht];
set(c.x.EvalStringTitle,'Position',pos);

pos=[pos(1)+pos(3) pos(2) evalBtnWid barht];
set(c.x.EvalNow,'Position',pos);

pos=[c.x.xzero+pad pos(2)-editht1 barwidth editht1];
set(c.x.EvalString,'Position',pos);

pos=[pos(1) pos(2)-barht-pad pos(3) barht];
set(c.x.isCatch,'Position',pos);

pos=[pos(1) pos(2)-editht2 pos(3) editht2];
set(c.x.CatchString,'Position',pos);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});

switch whichControl
case 'isCatch'
   set(c.x.CatchString,'Enable',LocOnOff(c.att.isCatch));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=EvalNow(c)

tempC=c;
tempC.att.isInsertString=logical(0);
tempC.att.isDiary=logical(0);
execute(tempC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end