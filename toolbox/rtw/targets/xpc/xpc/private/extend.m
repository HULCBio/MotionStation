function extend(system)
% EXTEND xPC Target private function.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2002/03/20 15:46:52 $

blockname=find_system(system,'Type','block','Parent',system)
syspos=get_param(gcs,'Location');
poscell=get_param(blockname,'position');
blkpos=cat(1,poscell{:});
Ymaxblk=max(blkpos(:,4));
Xmaxblk=max(blkpos(:,3));
if ( Xmaxblk > (syspos(3)-syspos(1)))
    syspos(3)=syspos(1)+Xmaxblk + 10;
end
if ( Ymaxblk > (syspos(4)-syspos(2)))
    syspos(4)=syspos(2)+Ymaxblk+10;
end
set_param(system,'location',syspos);

