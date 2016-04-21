function idoptcmp%(arg,hm,replot)
%IDOPTTOG Toggles checked frequency options for the compare menu.

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:19:29 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
pw=gcf;
if nargin<3,replot=1;end
if nargin<2
    hm=gcbo;%get(pw,'currentmenu');
end
usd=get(hm,'userdata');
set(hm,'checked','on');
set(usd(1),'checked','off')
iduiclpw(usd(2));

