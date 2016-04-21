function [usrdata,color,number]=getcolor(usrdata)

% GETCOLOR - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:19:26 $


colorwindow=figure('Visible','off');
usrdata.color.order=get(gca,'ColorOrder');
delete(colorwindow);
color=[];
for i=1:length(usrdata.edit.color.used)
   if usrdata.edit.color.used(i)==0 & isempty(color)
      color=usrdata.color.order(i,:);
      usrdata.edit.color.used(i)=1;
      number=i;
   end;
end;
if isempty(color)
   color=usrdata.color.order(1,:);
   usrdata.edit.color.used=zeros(length(usrdata.color.order),1);
   usrdata.edit.color.used(1)=1;
   number=1;
end;



