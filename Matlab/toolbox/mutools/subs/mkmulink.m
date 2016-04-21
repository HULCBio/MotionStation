% function out = mkmulink(expvar,name,tool,cbtool,retpim,onoff)
%
%
% mkmulink(dk_exp,'CONT',han_of_dk,han_of_sim,retpim,'on'_or_'off'
% example of DKIT establishing a export_to_sim

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = mkmulink(expvar,name,tool,cbtool,retpim,onoff)
    allhandles = get(tool,'userdata');
    pimnum = get(allhandles(2),'userdata');

%   h2v pointers
    gonumcol = 4;
    numlinks = 3;

    disp(onoff)

%   Update number of outgoing links associated with a variable
    namenum = h2v([],tool,name);
    if strcmp(onoff,'on')
        pimnum(namenum(gonumcol),numlinks) = pimnum(namenum(gonumcol),numlinks) + 1;
        botrow = [namenum(gonumcol) cbtool retpim];
        out = [expvar;botrow];
    else
        botrow = [namenum(gonumcol) cbtool retpim];
        linkloc = find(all(expvar(:,1)==botrow(1) & ...
            expvar(:,2)==botrow(2) & expvar(:,3)==botrow(3)));  % get rid of these
        if length(linkloc) > 0
            pimnum(namenum(gonumcol),numlinks) = ...
                pimnum(namenum(gonumcol),numlinks) - length(linkloc);
            keep = comple(linkloc,size(expvar,1));
            expvar = expvar(keep,:);
        end
    end
    set(allhandles(2),'userdata',pimnum);