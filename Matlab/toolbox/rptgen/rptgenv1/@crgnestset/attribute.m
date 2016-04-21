function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:17 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

rptFrame=controlsframe(c,'Setup File to Run');

c=controlsmake(c);


c.x.DescTitle=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Description of selected setup file');

c.x.Desc=uicontrol(c.x.all,...
   'style','edit',...
   'max',2,'min',0,...
   'HorizontalAlignment','left',...
   'Enable','inactive');

rptFrame.FrameContent={
   [3]
   num2cell(c.x.FileName)
   [3]
   {
      c.x.InlineTitle num2cell(c.x.Inline')
      [3] [3]   
      c.x.RecursionLimitTitle c.x.RecursionLimit
   }
};

c.x.LayoutManager={5
   rptFrame
   [5]
   c.x.DescTitle
   c.x.Desc};

GetDescription(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

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
   GetDescription(c);
case 'RecursionLimit'
   if c.att.RecursionLimit<0
      c.att.RecursionLimit=0;
      errMsg='Recursion limit mustbe greater than zero';
   elseif c.att.RecursionLimit>get(0,'RecursionLimit')
      c.att.RecursionLimit=get(0,'RecursionLimit');
      errMsg='Recursion limit must be less than the built-in limit';
   elseif floor(c.att.RecursionLimit)<c.att.RecursionLimit
      c.att.RecursionLimit=floor(c.att.RecursionLimit);
      errMsg='Recursion limit must be an integer';
   else
      errMsg='';
   end
   set(c.x.RecursionLimit,...
      'String',num2str(c.att.RecursionLimit));
   statbar(c,errMsg,1);
   
end

%--------1---------2---------3---------4---------5---------6---------7---------8
function GetDescription(c)


if isempty(c.att.FileName)
   fDesc='Warning - no setup file specified';
else
   if length(c.att.FileName)>2 & ...
         strncmp(c.att.FileName,'%<',2) & ...
         strncmp(c.att.FileName(end),'>',1)
      evalStr=c.att.FileName(3:end-1);
      try
         fileName=evalin('base',evalStr);
      catch
         fileName=[];
      end
   else
      fileName=c.att.FileName;
   end
   
   if ~ischar(fileName)
      fDesc='Warning - expression does not evaluate to a string';
   else
      oldStatus=nenw(c);
      try
         rptHandle=hgload(fileName);
      catch
         rptHandle=[];
      end
      nenw(c,oldStatus);
      
      fDesc=sprintf('Error: Could not load setup file "%s"', ...
            fileName );
      if ishandle(rptHandle)
         olHandle=findall(allchild(rptHandle),'flat',...
            'type','uimenu');
         if ~isempty(olHandle)
            olUD=get(olHandle,'UserData');
            if isstruct(olUD) & isfield(olUD,'att')
               if isstruct(olUD.att) & isfield(olUD.att,'Description')
                  fDesc=getfield(olUD.att,'Description');
               end
            end
         end
         delete(rptHandle);
      end
   end
end

set(c.x.Desc,'String',fDesc);
   

