% function [out] = grabvar(fignum,varname);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out] = grabvar(fignum,varname);

% DTI = str2mat('Controller','BlkStruct','#meas',`#controls','Olic');
% DTO = str2mat('CONT','BLKSYN','NMEAS','NCNTRL','OLIC');

    allfigs = get(0,'children');
    if any(allfigs==fignum)
        dbv = deblank(varname);
        [TLN,ULN] = gguivar('TLINKNAMES','ULINKNAMES',fignum);
        goo = 1;
        sexist = 0;
        i = 1;
        while i<=size(ULN,1) & goo == 1
                if strcmp(deblank(ULN(i,:)),dbv)
                    goo = 0;
                    varname = deblank(TLN(i,:));
                    out = gguivar(varname,fignum);
                    sexist = 1;
                else
                    i = i+1;
                end
        end
        if sexist == 0
            out = [];
        end
    else
        out = [];
    end