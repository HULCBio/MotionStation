function flag = isfdt(fdt)
%ISFDT  Check whether input is a Filter Design Tool specification structure.
%       isfdt(x) returns 1 is x is a scalar structure which 
%       matches the specifications structure of the filter design tool
%       of the signal processing toolbox.  It returns 0 otherwise.
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    flag = 1;

    if ~isstruct(fdt)
        flag = 0;
        return
    end

    f = fieldnames(fdt);

    if ~any(strcmp(f,'type'))|...
       ~any(strcmp(f,'method'))|...
       ~any(strcmp(f,'f'))|...
       ~any(strcmp(f,'Rp'))|...
       ~any(strcmp(f,'Rs'))|...
       ~any(strcmp(f,'Fs'))|...
       ~any(strcmp(f,'order'))|...
       ~any(strcmp(f,'special'))|...
       length(fdt)~=1
        flag = 0;
        return
    end

    if any(fdt.f<0) | any(diff(fdt.f<=0)) 
        flag = 0;
    end
