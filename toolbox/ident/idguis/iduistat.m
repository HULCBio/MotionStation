function iduistat(string,flag,window)
%IDUISTAT Manages the status line in main ident window.
%   STRING: What to display on the status line
%   FLAG: If flag is =1, then the STRING is added to the current status
%   line, otherwise it replaces the old string.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:41 $

%global XIDstatus
 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if nargin<3,window=16;end
if nargin<2,flag=0;end
if flag
 str1=get(XID.status(window),'string');
 string=[str1,' ',string];
end
eval('set(XID.status(window),''string'',string)','')
drawnow
