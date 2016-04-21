function proc = p_getProcessorType(cc,opt)
% P_GETPROCESSORTYPE (Private) Returns the processor type.
%  Example:
%  1. Input is a CCSDSP handle
%      >> cc = ccsdsp;
%      >> proctype = p_getProcessorType(cc)
%         proctype = 
%             'TMS320C6711'
%  2. Input is info(cc) - used in demos
%      >> cc = ccsdsp;
%      >> ccinfo = info(cc);
%      >> proctype = p_getProcessorType(ccinfo)
%         proctype = 
%             'TMS320C6711'
%  3. Input can be an array of CCSDSP handles or info structs
%      >> cc = ccsdsp('boardnum',0)
%         Array of CCSDSP Objects:
%           API version              : 1.31
%           Board name               : OMAP3.1 Platform Simulator
%           Board number             : 0
%           Processor 0  (element 1) : TMS470R2xx (MPU, Not Running)
%           Processor 1  (element 2) : TMS320C5500 (DSP, Not Running)
%      >> proctype = p_getProcessorType(info(cc))
%         proctype = 
%             'TMS470R2xx'    'TMS320C5500'
%  4. Second input can 'complete','subfamily' or 'family'. If not
%  specified, the default is 'complete'.
%      >> proctype = p_getProcessorType(info(cc),'subfamily')
%         proctype = 
%             'R2x'    'C55x'
%      >> proctype = p_getProcessorType(info(cc),'family')
%         proctype = 
%             'R2x'    'C5x'
    
% Copyright 2004 The MathWorks, Inc.

error(nargchk(1,2,nargin));

if isa(cc,'ccs.ccsdsp')
    icc = info(cc);
elseif isa(cc,'struct')
    icc = cc;
else
    error('Invalid input to ''p_getProcessorType'' function.');
end

if nargin==1,
    opt = 'complete';
end
if isempty(strmatch(opt,{'complete','subfamily','family'},'exact'))
    error('Invalid input to ''p_getProcessorType'' function.');
end
    
ncc = length(icc);
for k = 1:ncc,

    if icc(k).family == 470, % OMAP ARM Rxx
        switch opt
            case 'complete'
                ProcFormat = 'TMS%03dR%1s';
            case 'subfamily'
                ProcFormat = 'R%1sx';
            case 'family'
                ProcFormat = 'R%1sx';
        end
    else % family==320 and others
        switch opt
            case 'complete'
                ProcFormat = 'TMS%03dC%2s';
            case 'subfamily'
                ProcFormat = 'C%2sx';
            case 'family'
                ProcFormat = 'C%1sx';
                subfamily = dec2hex(icc(k).subfamily);
                proc{k} = sprintf(ProcFormat,subfamily(1)); % complete answer
                ProcFormat = proc{k}; % see partner 2: so 'formatProcName' will not do anything anymore
        end
    end

    proc{k} = formatProcName(ProcFormat,icc(k),opt);

end


if ncc == 1
    proc = proc{1};
end

%--------------------------------------------------------------------------
function proc = formatProcName(proc,icc,opt)
switch opt
    case 'family'
        if isempty(findstr(proc,'%')),
            % see partner 1: used by family=320 (formatting is done in the previous function)
            return;
        else
            proc = sprintf(proc,dec2hex(icc.subfamily));
        end
    case 'subfamily'
        proc = sprintf(proc,dec2hex(icc.subfamily));
    case 'complete'
        proc = sprintf(proc,icc.family,dec2hex(icc.subfamily));
        try
            if icc.revfamily>=0 && icc.revfamily<=99
                proc = sprintf('%s%02d', proc,icc.revfamily);
            elseif icc.revfamily>=100 && icc.revfamily<=109
                proc = [proc dec2hex(icc.revfamily-100) 'x'];
            elseif icc.revfamily>=110 && icc.revfamily<=119
                proc = [proc 'x' dec2hex(icc.revfamily-110)];
            elseif icc.revfamily==127
                proc = [proc 'xx'];
            else
                % If a fluke occurs and revfamily is not in the above range, we
                % default to the old implementation
                proc = sprintf('%s%02d', proc,icc.revfamily);
            end
        catch
            % If a problem occurs in the above implementation, we default to the
            % old implementation
            proc = sprintf('%s%02d', proc,icc.revfamily);
        end
    otherwise
        % do nothing
end

% [EOF] p_getProcessorType.m