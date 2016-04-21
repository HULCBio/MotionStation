function  copyStaticSourceFiles (h, isMultiTasking, isGRTTarget)
% copy all static source files to working directory

% $RCSfile: copyStaticSourceFiles.m,v $
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:06:06 $
% Copyright 2003-2004 The MathWorks, Inc.

src = {};

ind = 1;
if (isGRTTarget)
    [src, ind] = addtic2000SrcFile (src, ind, 'ti_nonfinite.c');
end
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_CpuTimers.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_Adc.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_DefaultIsr.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_GlobalVariableDefs.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_PieCtrl.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_PieVect.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_SysCtrl.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_PieVect.c');
[src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_usDelay.asm');

% XXX this might be needed in one of the future versions
% if isa(target_state.ccsObj.ccsversion,'ccs.CurrCCSVersion')
%     [src, ind] = addtic2000SrcFile (src, ind, 'DSP281x_Headers_nonBIOS.cmd');
% end

if (isGRTTarget)
    src{ind} = fullfile(matlabroot,'rtw','c','src','rt_sim.c');
end

for i=1:length(src),
    cpcmd = ['dos(''copy ' src{i} ' "' pwd '"'');'];
    evalc(cpcmd);
end


%-------------------------------------------------------------------------------
function [src, ind] = addtic2000SrcFile (src, ind, thisSource)
src{ind} = fullfile(matlabroot,'toolbox','rtw','targets','tic2000','tic2000','src',thisSource);
ind = ind + 1;

% [EOF] copyStaticSourceFiles.m
