function statbar(p,message,isEmphasis)
%STATBAR shows a message in the setup file editor status bar
%   STATBAR(OBJ,MESSAGE) displays the message in the status
%     bar of the setup file editor.
%   STATBAR(OBJ,MESSAGE,ISEMPHASIS) displays the message
%     with or without emphasis

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:27 $

barhandle=[];
if isa(p,'rptgui')
   try
      barhandle=subsref(p,substruct('.','h',...
         '.','Main',...
         '.','statusbar'));
   end
elseif isa(p,'rptcomponent') | isa(p,'rptcp')
   try
      barhandle=subsref(p,substruct('.','x',...
         '.','statusbar'));
   end
end

if isempty(barhandle)
   sfeHandle=findall(allchild(0),'flat',...
      'type','figure',...
      'tag','Setup File Editor');
   if length(sfeHandle)>0
      barhandle=findall(allchild(sfeHandle),...
         'Style','edit',...
         'Tag','TextStatusBar');
   end
end


if nargin>2 & isEmphasis & ~isempty(message)
   textColor='red';
   fontStyle='bold';
   horizAlign='center';
   try
      beep
   end
else
   textColor=get(0,'defaultuicontrolforegroundcolor');
   fontStyle='normal';
   horizAlign='left';
end

set(barhandle,...
   'String',message,...
   'ForegroundColor',textColor,...
   'FontWeight',fontStyle);