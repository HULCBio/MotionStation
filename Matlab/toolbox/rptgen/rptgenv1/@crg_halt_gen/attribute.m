function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:56 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

mainFrame=controlsframe(c,'Options');

helpFrame=controlsframe(c,'Help');

c=controlsmake(c,{'isPrompt','PromptString'});

helpBox=uicontrol(c.x.all,...
   'style','text',...
   'string',help('crg_halt_gen'),...
   'HorizontalAlignment','left');

%c.x.TestButton=uicontrol(c.x.all,...
%      'String','Preview confirmation dialog',...
%      'Callback',[c.x.getobj,'''TestDialog'');']);

mainFrame.FrameContent={c.x.isPrompt
   {
      'indent' c.x.PromptStringTitle c.x.PromptString
   }
};
%      c.x.TestButton

helpFrame.FrameContent={helpBox};

c.x.LayoutManager={mainFrame
   [5]
   helpFrame};


c=resize(c);

set(c.x.PromptString,'Enable',...
   onoff(c.att.isPrompt));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});   
set(c.x.PromptString,'Enable',...
   onoff(c.att.isPrompt));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=TestDialog(c)

execute(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

