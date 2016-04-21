function hnr=iduiwok(k)
%IDUIWOK Checks if window number k in the ident GUI exists.
%      If it does, its handle number is returned, otherwise [] is returned.

%   L. Ljung 9-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:42 $

tag=['sitb',int2str(k)];
hnr=findobj(get(0,'children'),'flat','tag',tag);