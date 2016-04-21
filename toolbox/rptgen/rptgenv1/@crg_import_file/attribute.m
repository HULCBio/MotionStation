function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:03 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

mainFrame=controlsframe(c,'File to Import');
prevFrame=controlsframe(c,'File Content');

c=controlsmake(c);

c.x.PreviewWindow=uicontrol(c.x.all,...
   'String','',...
   'style','edit',...
   'Max',2,'Min',0,...  %'FontName',fixedwidthfont(c),...
   'HorizontalAlignment','left',... %'BackgroundColor','white',...
   'Enable','inactive');


mainFrame.FrameContent={
   num2cell(c.x.FileName)
   [2]
   {c.x.ImportTypeTitle (num2cell(c.x.ImportType'))}
};

prevFrame.FrameContent={c.x.PreviewWindow};

c.x.LayoutManager={mainFrame
   [2]
   prevFrame};

LocPreview(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});

switch whichControl
case 'FileName'
   LocPreview(c);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocPreview(c);

if ~isempty(c.att.FileName)
   fid=fopen(c.att.FileName,'r');
   if fid>0
      msgString=char(fread(fid,256,'char'))';
      fclose(fid);
      
      if ~isempty(msgString)
         
      else
         msgString=sprintf('Warning - File "%s" contains no ASCII text.', c.att.FileName);
      end
   else
      msgString=sprintf('Error - Could not open file "%s".',c.att.FileName);
   end
else
   msgString='Please specify a file to import';
end

set(c.x.PreviewWindow,'String',msgString);
