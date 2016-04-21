% function [out1,out2,out3,out4,out5,out6] = h2v(av,pimnum,in1,in2,in3,in4,in5,in6)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2,out3,out4,out5,out6] = h2v(av,pimnum,in1,in2,in3,in4,in5,in6)

%   This is called (VARIABLENAME is a string)
%   [han_index pim_index] = han2var(variablename)
if isempty(av)  % h2v([],main_figure,varnames)
    allhandles = get(pimnum,'userdata');
    av = get(allhandles(1),'userdata');
    pimnum = get(allhandles(2),'userdata');
end

idcol = 4;
pimoutcols = 1:3;

[dum,nc] = size(av);
if nargin >= 3
    in1 = deblank(in1);
    lin = length(in1)*(sum(abs(in1))-64*length(in1));
    loc = find(pimnum(:,idcol)==lin);   % these are the indices
    if length(loc) == 1
        out1 = [pimnum(loc,pimoutcols) loc];
    else
        tmp = '            ';
        tmp(1:length(in1)) = in1;
        id=sum(abs(av(:,loc) - tmp'*ones(1,length(loc))));  % indices local to loc
        go=loc(find(id==0));
        out1 = [pimnum(go,pimoutcols) go];     % 1x4 since pimoutcols = 1x3
    end
end
if nargin >= 4
    in2 = deblank(in2);
    lin = length(in2)*(sum(abs(in2))-64*length(in2));
    loc = find(pimnum(:,idcol)==lin);   % these are the indices
    if length(loc) == 1
        out2 = [pimnum(loc,pimoutcols) loc];
    else
        tmp = '            ';
        tmp(1:length(in2)) = in2;
        id=sum(abs(av(:,loc) - tmp'*ones(1,length(loc))));  % indices local to loc
        go=loc(find(id==0));
        out2 = [pimnum(go,pimoutcols) go];     % 1x4 since pimoutcols = 1x3
    end
end
if nargin >= 5
    in3 = deblank(in3);
    lin = length(in3)*(sum(abs(in3))-64*length(in3));
    loc = find(pimnum(:,idcol)==lin);   % these are the indices
    if length(loc) == 1
        out3 = [pimnum(loc,pimoutcols) loc];
    else
        tmp = '            ';
        tmp(1:length(in3)) = in3;
        id=sum(abs(av(:,loc) - tmp'*ones(1,length(loc))));  % indices local to loc
        go=loc(find(id==0));
        out3 = [pimnum(go,pimoutcols) go];     % 1x4 since pimoutcols = 1x3
    end
end
if nargin >= 6
    in4 = deblank(in4);
    lin = length(in4)*(sum(abs(in4))-64*length(in4));
    loc = find(pimnum(:,idcol)==lin);   % these are the indices
    if length(loc) == 1
        out4 = [pimnum(loc,pimoutcols) loc];
    else
        tmp = '            ';
        tmp(1:length(in4)) = in4;
        id=sum(abs(av(:,loc) - tmp'*ones(1,length(loc))));  % indices local to loc
        go=loc(find(id==0));
        out4 = [pimnum(go,pimoutcols) go];     % 1x4 since pimoutcols = 1x3
    end
end
if nargin >= 7
    in5 = deblank(in5);
    lin = length(in5)*(sum(abs(in5))-64*length(in5));
    loc = find(pimnum(:,idcol)==lin);   % these are the indices
    if length(loc) == 1
        out5 = [pimnum(loc,pimoutcols) loc];
    else
        tmp = '            ';
        tmp(1:length(in5)) = in5;
        id=sum(abs(av(:,loc) - tmp'*ones(1,length(loc))));  % indices local to loc
        go=loc(find(id==0));
        out5 = [pimnum(go,pimoutcols) go];     % 1x4 since pimoutcols = 1x3
    end
end
if nargin >= 8
    in6 = deblank(in6);
    lin = length(in6)*(sum(abs(in6))-64*length(in6));
    loc = find(pimnum(:,idcol)==lin);   % these are the indices
    if length(loc) == 1
        out6 = [pimnum(loc,pimoutcols) loc];
    else
        tmp = '            ';
        tmp(1:length(in6)) = in6;
        id=sum(abs(av(:,loc) - tmp'*ones(1,length(loc))));  % indices local to loc
        go=loc(find(id==0));
        out6 = [pimnum(go,pimoutcols) go];     % 1x4 since pimoutcols = 1x3
    end
end