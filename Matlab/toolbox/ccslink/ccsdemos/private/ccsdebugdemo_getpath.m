function [demopath,srcpath] = ccsdebugdemo_getpath(cc,exname)
% For CCSDEBUGDEMO: returns the demo path of the CCS project that
% corresponds to a particular DSP target.

%   Copyright 2004 The MathWorks, Inc.

ccinfo = info(cc);
ccsdebugdemopath = [matlabroot,'\toolbox\ccslink\ccsdemos\debug\'];
srcpath = [matlabroot,'\toolbox\ccslink\ccsdemos\debug\shared\'];
switch exname
    case {'ex1','ex6'}
        if ccinfo.family==320,
            proc = ['TMS' num2str(ccinfo.family) 'C' dec2hex(ccinfo.subfamily) 'x'];
            if ccinfo.subfamily==103 || ccinfo.subfamily==98
                if ccinfo.isbigendian
                    demopath = [ccsdebugdemopath,'FilterFFT_c6700_be'];
                else
                    demopath = [ccsdebugdemopath,'FilterFFT_c6700'];
                end
            elseif ccinfo.subfamily==100 
                isPrevCCSVer = strcmpi(class(cc.ccsversion),'ccs.PrevCCSVersion');
                if isPrevCCSVer
                    addtlpath = 'FilterFFT_ccs2p12\'; % CCS 2.12 only
                else
                    addtlpath = '';
                end
                if ccinfo.isbigendian
                    demopath = [ccsdebugdemopath,addtlpath,'FilterFFT_c6400_be'];
                else
                    demopath = [ccsdebugdemopath,addtlpath,'FilterFFT_c6400'];
                end
            elseif ccinfo.subfamily==36
                if isC2401(cc)
                    error(['This demo does not run on the C2401 processor.']);
                end
                demopath = [ccsdebugdemopath,'FilterFFT_c2400'];
            elseif ccinfo.subfamily==39
                demopath = [ccsdebugdemopath,'FilterFFT_c2700'];
            elseif ccinfo.subfamily==40
                demopath = [ccsdebugdemopath,'FilterFFT_c2800'];
                if strcmp(ccinfo.targettype,'simulator')
                    demopath = [demopath,'sim'];
                end
            elseif ccinfo.subfamily==84
                demopath = [ccsdebugdemopath,'FilterFFT_c5400'];
            elseif ccinfo.subfamily==85 && strcmp(exname,'ex1')
                demopath = [ccsdebugdemopath,'FilterFFT_c5500'];
            else
                ThrowError(proc);
            end
        elseif ccinfo.family==470,
            proc = ['TMS' num2str(ccinfo.family) 'R' dec2hex(ccinfo.subfamily) 'x'];
            if ccinfo.subfamily==1 
                if ccinfo.isbigendian
                    demopath = [ccsdebugdemopath,'FilterFFT_r1x_be'];
                else
                    demopath = [ccsdebugdemopath,'FilterFFT_r1x'];
                end
            elseif ccinfo.subfamily==2 
                if ccinfo.isbigendian
                    demopath = [ccsdebugdemopath,'FilterFFT_r2x_be'];
                else
                    demopath = [ccsdebugdemopath,'FilterFFT_r2x'];
                end
            else
                ThrowError(proc);
            end
        else
            ThrowError;
        end
    case 'ex2'
        % to do
    otherwise
end

%---------------------------------------------
function ThrowError(proc)
if nargin==0
    error('This demo does not run on this processor.');
else
    error(['This demo does not run on the ' proc ' processor.']);
end

% [EOF] ccsdebugdemo_getpath.m
