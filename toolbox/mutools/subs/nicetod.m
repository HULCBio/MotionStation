% function out = nicetod(in)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = nicetod(in)
    if nargin == 1
        comm = ',';
    else
        comm = ' ';
    end
    day = date;
    tod = fix(clock);
    str1 = int2str(tod(4));
    if length(str1)==1
        str1 = ['0' str1];
    end
    str2 = int2str(tod(5));
    if length(str2)==1
        str2 = ['0' str2];
    end
    str3 = int2str(tod(6));
    if length(str3)==1
        str3 = ['0' str3];
    end
    out = [date comm '   ' str1 ':' str2 ':' str3];