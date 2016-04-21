function reglist = addregister(ff,rlist)
% ADDREGISTER Adds register(s) from the saved-register list.
%   ADDREGISTER(FF,REGLIST) Adds register(s), specified in
%   REGLIST, from the existing saved-register list, FF.SAVEDREGS.
%   FF.SAVEDREGS contains a list of save-on-call registers.
%   REGLIST can be a single register (string) or an array of register names
%   (cell array).
%
%   Note: Register(s) can be directly added from ff.savedregs without
%   using 'addregister'.
%
%   See also DELETEREGISTER.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2003/11/30 23:08:11 $

error(nargchk(2,2,nargin));
if ~ishandle(ff),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a FUNCTION Handle.');
end
if ~ischar(rlist) & ~iscellstr(rlist)
    error(generateccsmsgid('InvalidInput'),'Second Parameter must be a string or a cell array of strings');
end

if ischar(rlist) 
    rlist = { rlist };
end

% C28x check
rlist = C28x_CheckForAuxillaryRegs(ff,rlist);

% filter out existing registers
if any(ismember(rlist,ff.savedregs))
    [a,b] = ismember(rlist,ff.savedregs);
    rlist(a) = [];
end

if iscellstr(rlist)
    temp = ff.savedregs;
    ff.savedregs      = horzcat(temp,rlist);
    if length(ff.savedregs)>length(ff.savedregsvalue)
        ff.savedregsvalue = horzcat(ff.savedregsvalue,zeros(1,length(rlist)));
    end    
    reglist = ff.savedregs;    
end

%-----------------------------------------
function rlist = C28x_CheckForAuxillaryRegs(ff,rlist)
if ~strcmp(ff.procsubfamily,'C28x')
    return
end
% If register name is the 16-bit counterpart, add the 22-bit counterpart
rlist = upper(rlist);
[ismem,idx] = ismember({'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7'},rlist);
idx = idx(find(idx~=0));
for i=1:length(idx)
    rlist{i} = ['X' rlist{i}];
end

% [EOF] addregister.m