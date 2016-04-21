% function [mainw,othw,notours,splts] = findmuw(all)
%
% find the handles of the MAIN mutools windows, other
%   mutools windows, and windows that are not mutools.
%
%   See also: mkours

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [mainw,othw,notours,splts] = findmuw(all)

mainw = [];
othw = [];
notours = [];
splts = [];

% all = get(0,'children');
if nargin < 1               % might not see hidden ones though..
  all = get(0,'chi');
end

%disp('findmuw called with:');
%disp(all)

for i=1:length(all)
    ud = get(all(i),'userdata');
    lud = length(ud);
    if lud > 4
        iden = setstr(fix(ud(lud-3:lud)'));
        if strcmp('MAIN',iden)
            mainw = [mainw ; all(i)];
        elseif strcmp('SUB',iden(1:3))  % ud(lud) is mainwin.subwin (max of 99)
            mainwin = floor(ud(lud));
            subwin = round(100*(ud(lud)-mainwin));
            subs = xpii(othw,mainwin);      % othw is PIM
            subs = [subs;all(i) subwin];    % subs, Mx2, [handle identifier]
            othw = ipii(othw,subs,mainwin);
        elseif strcmp('SPLT',iden)  % Simulation plot windows
            if strcmp('SUB',setstr(ud(lud-7:lud-5)'))  % ud(lud-4) is mainwin.subwin (max of 99)
                  mainwin = floor(ud(lud-4));
                  subwin = round(100*(ud(lud-4)-mainwin));
                  subs = xpii(othw,mainwin);      % othw is PIM
                  subs = [subs;all(i) subwin];    % subs, Mx2, [handle identifier]
                  othw = ipii(othw,subs,mainwin);
                  splt = xpii(splts,mainwin);
                  splt = [splt;all(i) subwin];
                  splts = ipii(splts,splt,mainwin);
            end
        else
            notours = [notours;all(i)];
        end
    else
        notours = [notours;all(i)];
    end
end