function iduiaxis(arg,window)
%IDUIAXIS Sets up the axes limits dialog (axlimdlg) for ident plots.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:36 $

winname = get(window,'name');
col = find(winname==':'); if ~isempty(col),winname=winname(1:col-1);end
dlgname = ['Limits for ',winname];
len = length(dlgname);
axis1=findobj(get(window,'children'),'flat','tag','axis1');
axis2=findobj(get(window,'children'),'flat','tag','axis2');
if isempty(axis2)
   xstr = get(get(axis1,'xlabel'),'string');
else
   xstr = get(get(axis2,'xlabel'),'string');
end
if isempty(xstr),xstr='x-axis';end

% The following is just to force the dialog box to show its own name

font_factor = 0.8;
no_blanks=ceil(len*font_factor-length(xstr));
if no_blanks>0,xstr=[xstr,setstr(32*ones(1,no_blanks))];end

y1str = get(get(axis1,'ylabel'),'string');
if isempty(y1str),y1str='y-axis';end
Prompt=str2mat(xstr,y1str);
Axhand=[axis1,NaN,axis1];
xyz=['x';'y'];
if ~isempty(axis2)
   Axhand=[axis1,axis2,NaN,axis1,NaN,axis2];
   Prompt=str2mat(Prompt,get(get(axis2,'ylabel'),'string'));
   xyz=[xyz;'y'];
end
fig=axlimdlg(dlgname,[1 1],Prompt,Axhand,xyz);
set(fig,'tag','sitb');  % Just to clear when exiting ident