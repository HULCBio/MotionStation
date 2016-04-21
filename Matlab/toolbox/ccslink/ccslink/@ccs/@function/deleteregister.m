function reglist = deleteregister(ff,rlist)
% DELETEREGISTER Deletes register(s) from the saved-register list.
%   DELETEREGISTER(FF,REGLIST) Deletes register(s), specified in
%   REGLIST, from the existing saved-register list, FF.SAVEDREGS.
%   REGLIST can be a single register (string) or an array of register names
%   (cell array).
%
%   Note: Register(s) can be directly deleted from ff.savedregs without
%   using 'deleteregister'.
%
%   See also ADDREGISTER.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2003/11/30 23:08:19 $

error(nargchk(2,2,nargin));
if ~ishandle(ff),
    error('First Parameter must be a FUNCTION Handle.');
end
if ~ischar(rlist) & ~iscellstr(rlist)
    error('Second Parameter must a string or a cell array of strings');
end
    
if ischar(rlist) 
    rlist = { rlist };
end

% C28x check
rlist = C28x_CheckForAuxillaryRegs(ff,rlist);

if iscellstr(rlist)
    rlist = upper(rlist);
    if all(ismember(ff.savedregs,rlist)==0)
        error('You are deleting a register that is not on the saved-register list.');
        return;
    end
    index_of_retained_reg = find(ismember(ff.savedregs,rlist)==0);
    ff.savedregs          = { ff.savedregs{index_of_retained_reg} };
    ff.savedregsvalue     = ff.savedregsvalue(index_of_retained_reg);
    reglist = ff.savedregs;
end

%-----------------------------------------
function rlist = C28x_CheckForAuxillaryRegs(ff,rlist)
if ~strcmp(ff.procsubfamily,'C28x')
    return
end
% If register name is the 16-bit counterpart, delete the 22-bit counterpart
rlist = upper(rlist);
[ismem,idx] = ismember({'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7'},rlist);
idx = idx(find(idx~=0));
for i=1:length(idx)
    rlist{i} = ['X' rlist{i}];
end

% [EOF] deleteregister.m