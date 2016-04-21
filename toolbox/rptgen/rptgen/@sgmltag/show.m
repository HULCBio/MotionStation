function h=show(t)
%SHOW displays an SGMLTAG object graphically
%   SHOW(T) creates a visual representation of the
%   SGMLTAG object T by putting each tag and tag
%   data element into a uimenu.  The object and
%   its children can be browsed from the menus.
%
%   Note that the menus are not a live representation
%   of the object so moving the menus will not cause
%   the object to change.
%
%   This method is useful mainly for debugging.  A
%   text representation of the object can be obtained
%   through SPRINTF(T).
%
%   SEE ALSO: SGMLTAG, SGMLTAG/SPRINTF

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:41 $

h=figure('BackingStore','off',...
   'HitTest','off',...
   'IntegerHandle','off',...
   'Interruptible','off',...
   'MenuBar','none',...
   'Name','sgmltag object viewer',...
   'NumberTitle','off',...
   'Position',[150 150 50 50],...
   'Renderer','painters',...
   'RendererMode','manual',...
   'Tag','SGMLTAG_OBJECT_VIEWER',...
   'Visible','on');

LocProcess(t,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocProcess(data,pH)

processChildren=logical(0);
makeHandle=logical(1);
switch class(data)
case 'cell'
   myLabel='';
   for i=1:length(data)
      LocProcess(data{i},pH);
   end
   makeHandle=logical(0);
case 'char'
   tempData=data';
   myLabel=strrep(tempData(:)',sprintf('\n'),' ');
case 'double'
   myLabel=num2str(data);
case 'sgmltag'
   processChildren=logical(1);
   myLabel=['<' data.tag '>'];
otherwise
   myLabel='[unrecognized data type]';
end

if makeHandle
   h=uimenu('Label',myLabel,...
      'Parent',pH,...
      'UserData',data,...
      'Callback','sgmlBrowse=get(gcbo,''UserData'')');
   if processChildren
      LocProcess(data.data,h);  
   end
end

