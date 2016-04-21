function [data,data_info,data_n,handles] = iduigetd(type,mode)
%IDUIGETD Gets the desired active data set
%   TYPE: 'e' The Estimation data set is returned
%   TYPE: 'v' The Validation data set is returned
%   DATA: The data
%   DATA_INFO: The corresponding information matrix
%   DATA-N: The data name
%   handles: The handles [kax,klin,kname].

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:19:41 $

set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles','off')
XID = get(Xsum,'Userdata');
if nargin<2
    mode = [];
end
if type=='e',
    hax=XID.hw(3,1);
elseif type=='v',
    hax=XID.hw(4,1);
end

hnrdat=findobj(hax,'tag','selline');
hnrstr=findobj(hax,'tag','name');
data=get(hnrdat,'UserData');
if isa(data,'idfrd')
    if ~isempty(mode)
        if strcmp(mode,'me')
            data = iddata(data,'me');
        else
            data = iddata(data);
        end
    end
end
data_info = iduiinfo('get',data);%get(hnrstr,'UserData');
data_n = pvget(data,'Name');%get(hnrstr,'String');
handles=[hax,hnrdat,hnrstr];
