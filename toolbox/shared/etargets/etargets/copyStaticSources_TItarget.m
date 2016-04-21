function  copyStaticSources_TItarget(isMultiTasking)
% copy all static source files to working directory

% $RCSfile: copyStaticSources_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:33:51 $
% Copyright 2001-2004 The MathWorks, Inc.

% Only copy this file if using GRT-based target.
cs = getActiveConfigSet(gcs);
if strcmp(get_param(cs,'SystemTargetFile'),'ti_c6000.tlc'),

    src{1} = fullfile(matlabroot,'rtw','c','src','rt_sim.c');

    for i=1:length(src),
        cpcmd = ['dos(''copy ' src{i} ' "' pwd '"'');'];
        evalc(cpcmd);
    end

end
    
% [EOF] copyStaticSources.m
