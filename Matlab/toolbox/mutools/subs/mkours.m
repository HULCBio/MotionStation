% function mkours(handles,mainw,sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8,sub9,...
%             sub10,sub11,sub12,sub13,sub14,sub15)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function mkours(handles,mainw,sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8,sub9,...
            sub10,sub11,sub12,sub13,sub14,sub15)

    handles = handles(:);
    set(mainw,'userdata',[handles;abs('MAIN')']);
    for i=3:nargin
        st = ['set(sub' int2str(i-2)];
        st = [st ',''Userdata'',[handles; abs(''SUB'')'';mainw+(('];
        st = [st int2str(i) '-2)/100)]);'];
        eval(st)
    end