function c=attribute_summ_table(c,action,varargin)
%ATTRIBUTE_SUMM_TABLE
%   A special version of the attributes page for use with
%   the summary table component.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:04 $

c=feval(action,c,varargin{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Report On');

c=controlsmake(c,{'LoopType'});

customList=c.att.CustomModels;
customList={customList.MdlName};
customList=customList(:);

c.x.CustomModelList=uicontrol(c.x.all,...
   'Style','edit',...
   'Min',0,...
   'Max',2,...
   'String',customList,...
   'BackgroundColor',[1 1 1],...
   'HorizontalAlignment','left',...
   'Callback',...
   [c.x.getobj,'''Update'',''CustomModelList'');']);

loopFrame.FrameContent={
   c.x.LoopType(1)
   c.x.LoopType(2)
   c.x.LoopType(3)
   {'indent' c.x.CustomModelList}
   [3]
};

c.x.LayoutManager={loopFrame};

set(c.x.CustomModelList,'Enable',...
   LocOnOff(strcmp(c.att.LoopType,'Custom')));


c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

switch whichControl
case 'LoopType'
   c=controlsupdate(c,whichControl,varargin{:});
   set(c.x.CustomModelList,'Enable',...
      LocOnOff(strcmp(c.att.LoopType,'Custom')));
case 'CustomModelList'
   customList=get(c.x.CustomModelList,'String');
   c.att.CustomModels=struct('isActive',1,...
      'MdlName',customList,...
      'MdlCurrSys',{{'top'}},...
      'SysLoopType','$all',...
      'isMask','graphical',...
      'isLibrary','off');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=LocOnOff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end
