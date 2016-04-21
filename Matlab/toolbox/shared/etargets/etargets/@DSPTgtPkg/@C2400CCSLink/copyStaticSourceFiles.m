function  copyStaticSourceFiles (h, isMultiTasking, isGRTTarget)
% copy all static source files to working directory

% $RCSfile: copyStaticSourceFiles.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:52 $
% Copyright 2003-2004 The MathWorks, Inc.

src = {};

ind = 1;
if (isGRTTarget)
    [src, ind] = addtic2000SrcFile (src, ind, 'ti_nonfinite.c');
end
[src, ind] = addtic2000SrcFile (src, ind, 'DSP24_GlobalVariableDefs.c');
[src, ind] = addtic2000SrcFile (src, ind, 'WD_disable.asm');

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