function board = GetDemoProp(cc,demoName)
% GETDEMOPROP (Private)
% Only used with demos - ccstutorial,ccsfirdemo,rtdxlmsdemo,rtdxtutorial.
% Returns a board structure of the necessary information (file names,
% projects names, board name, ...) for the requested target family, which
% is used by the above listed demos.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/01 15:59:25 $

[proc,bigE] = getproc(cc);
board.name = proc;
isPrevCCSVer = strcmpi(class(cc.ccsversion),'ccs.PrevCCSVersion');

if strcmpi(proc, 'c28x') 
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_28xx.pjt';
            board.ccstut.loadfile = 'ccstut_28xx.out';
            board.ccstut.Cbuildopt = '-g -q -d"_DEBUG" -ml -v28';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_28xx.pjt';
            board.hiltut.loadfile = 'hiltut_28xx.out';
            board.ccstut.Cbuildopt = '-g -q -d"_DEBUG" -ml -v28';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_28xx.pjt';
            board.ccsfir.loadfile = 'a28xx.out';
            board.ccsfir.Cbuildopt = '-g -q -d"_DEBUG" -ml -v28';
        case 'rtdxtutorial'
            board.rtdxtutsim = '';
            board.rtdxtutsim.loadfile = '';
            board.rtdxtutsim.dir = ''; 
            board.rtdxtutsim.Cbuildopt = '';
            board.rtdxtut.projname = 'rtdxtutorial_28x.pjt';
            board.rtdxtut.loadfile = 'rtdxtutorial_28x.out';
            board.rtdxtut.dir = 'c2x'; 
            board.rtdxtut.Cbuildopt = '-g -as';
        case 'rtdxlmsdemo'
            board.rtdxdemosim.projname = '';
            board.rtdxdemosim.loadfile = '';
            board.rtdxdemosim.dir = ''; 
            board.rtdxdemosim.Cbuildopt = '';
            board.rtdxdemo.projname = 'rtdxdemo_28x.pjt';
            board.rtdxdemo.loadfile = 'rtdxdemo_28x.out';
            board.rtdxdemo.dir = 'c2x'; 
            board.rtdxdemo.Cbuildopt = '-g -as';
    end
    
elseif strcmpi(proc, 'c24x') 
    switch(demoName)
        case 'ccstutorial'
            if isC2401(cc)
                board.ccstut.projname = 'ccstut_2401.pjt';
                board.ccstut.loadfile = 'ccstut_2401.out';
            else
                board.ccstut.projname = 'ccstut_24xx.pjt';
                board.ccstut.loadfile = 'ccstut_24xx.out';
            end
            board.ccstut.Cbuildopt = '-g -q -d"_DEBUG" -v2xx';
        case 'hiltutorial'      
            board.hiltut = [];
        case 'ccsfirdemo'
            if isC2401(cc)
                board.ccstut.projname = '';
                board.ccstut.loadfile = '';
            else
                board.ccsfir.projname = 'ccsfir_24xx.pjt';
                board.ccsfir.loadfile = 'a24xx.out';
            end
            board.ccsfir.Cbuildopt = '-g -q -d"_DEBUG" -v2xx';
        case 'rtdxtutorial'
            board.rtdxtutsim = ''; % C24x does not support rtdx for now (May 2003)
            board.rtdxtut = '';
        case 'rtdxlmsdemo'
            board.rtdxdemosim = '';
            board.rtdxdemo = '';
    end
    
elseif strcmpi(proc, 'c27x') 
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_27xx.pjt';
            board.ccstut.loadfile = 'ccstut_27xx.out';
            board.ccstut.Cbuildopt = '-g -q -d"_DEBUG" -v27';
        case 'hiltutorial'      
            board.hiltut = [];
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_27xx.pjt';
            board.ccsfir.loadfile = 'a27xx.out';
            board.ccsfir.Cbuildopt = '-g -q -d"_DEBUG" -v27';
        case 'rtdxtutorial'
            board.rtdxtutsim = ''; % c27x does not support RTDX
            board.rtdxtut = '';
        case 'rtdxlmsdemo'
            board.rtdxdemosim = '';
            board.rtdxdemo = '';
    end
    
elseif strcmpi(proc, 'c54x') 
    switch(demoName)
        case 'ccstutorial'      
            board.ccstut.projname = 'ccstut_54xx.pjt';
            board.ccstut.loadfile = 'ccstut_54xx.out';
            board.ccstut.Cbuildopt = '-g -as';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_54xx.pjt';
            board.hiltut.loadfile = 'hiltut_54xx.out';
            board.hiltut.Cbuildopt = '-g -as';
        case 'ccsfirdemo'
            if isPrevCCSVer
                board.ccsfir.projname = 'ccsfir_54xx_ccs2p12.pjt';
                board.ccsfir.loadfile = 'a54xx_ccs2p12.out';
                board.ccsfir.Cbuildopt = '-g -as';
            else
                board.ccsfir.projname = 'ccsfir_54xx.pjt';
                board.ccsfir.loadfile = 'a54xx.out';
                board.ccsfir.Cbuildopt = '-g -as';
            end
        case 'rtdxtutorial'
            board.rtdxtutsim.projname = 'rtdxtutorial_sim54x.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim54x.out';
            board.rtdxtutsim.dir = 'c5x'; 
            board.rtdxtutsim.Cbuildopt = '-g -as';
            board.rtdxtut.projname = 'rtdxtutorial_5x.pjt';
            board.rtdxtut.loadfile = 'rtdxtutorial_5x.out';
            board.rtdxtut.dir = 'c5x'; 
            board.rtdxtut.Cbuildopt = '-g -as';
        case 'rtdxlmsdemo'
            if isPrevCCSVer
                board.rtdxdemosim.projname = 'rtdxdemo_sim54x_ccs2p12.pjt';
                board.rtdxdemosim.loadfile = 'rtdxdemo_sim54x_ccs2p12.out';
                board.rtdxdemosim.dir = 'c5x';
                board.rtdxdemosim.Cbuildopt = '-g -as';
                board.rtdxdemo.projname = 'rtdxdemo_5x_ccs2p12.pjt';
                board.rtdxdemo.loadfile = 'rtdxdemo_5x_ccs2p12.out';
                board.rtdxdemo.dir = 'c5x';
                board.rtdxdemo.Cbuildopt = '-g -as';
            else
                board.rtdxdemosim.projname = 'rtdxdemo_sim54x.pjt';
                board.rtdxdemosim.loadfile = 'rtdxdemo_sim54x.out';
                board.rtdxdemosim.dir = 'c5x';
                board.rtdxdemosim.Cbuildopt = '-g -as';
                board.rtdxdemo.projname = 'rtdxdemo_5x.pjt';
                board.rtdxdemo.loadfile = 'rtdxdemo_5x.out';
                board.rtdxdemo.dir = 'c5x';
                board.rtdxdemo.Cbuildopt = '-g -as';
            end
    end
    
elseif strcmpi(proc, 'c55x') 
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_55xx.pjt';
            board.ccstut.loadfile = 'ccstut_55xx.out';
            board.ccstut.Cbuildopt = '-g -as';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_55xx.pjt';
            board.ccsfir.loadfile = 'a55xx.out';
            board.ccsfir.Cbuildopt = '-g -as';
        case 'rtdxtutorial'
            if isPrevCCSVer
                board.rtdxtutsim.projname = 'rtdxtutorial_sim55x_ccs2p12.pjt'; % intvecs.asm can be old or new version
                board.rtdxtutsim.loadfile = 'rtdxtutorial_sim55x_ccs2p12.out';
                board.rtdxtutsim.Cbuildopt = '-g -as';
                board.rtdxtutsim.dir = 'c5x';
                board.rtdxtut.projname = 'rtdxtutorial_55x_ccs2p12.pjt';
                board.rtdxtut.loadfile = 'rtdxtutorial_55x_ccs2p12.out';
                board.rtdxtut.Cbuildopt = '-g -as';
                board.rtdxtut.dir = 'c5x';
            else
                board.rtdxtutsim.projname = 'rtdxtutorial_sim55x.pjt';
                board.rtdxtutsim.loadfile = 'rtdxtutorial_sim55x.out';
                board.rtdxtutsim.Cbuildopt = '-g -as';
                board.rtdxtutsim.dir = 'c5x';
                board.rtdxtut.projname = 'rtdxtutorial_55x.pjt';
                board.rtdxtut.loadfile = 'rtdxtutorial_55x.out';
                board.rtdxtut.Cbuildopt = '-g -as';
                board.rtdxtut.dir = 'c5x';
            end
        case 'rtdxlmsdemo'
            if isPrevCCSVer
                board.rtdxdemosim.projname = 'rtdxdemo_sim55x_ccs2p12.pjt'; % intvecs.asm can be old or new version
                board.rtdxdemosim.loadfile = 'rtdxdemo_sim55x_ccs2p12.out';
                board.rtdxdemosim.dir = 'c5x';
                board.rtdxdemosim.Cbuildopt = '-g -as';
                board.rtdxdemo.projname = 'rtdxdemo_55x_ccs2p12.pjt';
                board.rtdxdemo.loadfile = 'rtdxdemo_55x_ccs2p12.out';
                board.rtdxdemo.Cbuildopt = '-g -as';
                board.rtdxdemo.dir = 'c5x';
            else
                board.rtdxdemosim.projname = 'rtdxdemo_sim55x.pjt';
                board.rtdxdemosim.loadfile = 'rtdxdemo_sim55x.out';
                board.rtdxdemosim.dir = 'c5x';
                board.rtdxdemosim.Cbuildopt = '-g -as';
                board.rtdxdemo.projname = 'rtdxdemo_55x.pjt';
                board.rtdxdemo.loadfile = 'rtdxdemo_55x.out';
                board.rtdxdemo.Cbuildopt = '-g -as';
                board.rtdxdemo.dir = 'c5x';
            end
    end
    
elseif strcmpi(proc, 'c67x') && bigE,
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_67xe.pjt';
            board.ccstut.loadfile = 'ccstut_67xe.out';
            board.ccstut.Cbuildopt = '-g -as -me';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_67xe.pjt';
            board.hiltut.loadfile = 'hiltut_67xe.out';
            board.hiltut.Cbuildopt = '-g -as -me';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_67xe.pjt';
            board.ccsfir.loadfile = 'a67xe.out';
            board.ccsfir.Cbuildopt = '-g -as -me';
        case 'rtdxtutorial'
            board.rtdxtutsim.projname = 'rtdxtutorial_sim67xe.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim67xe.out';
            board.rtdxtutsim.Cbuildopt = '-g -as -me';
            board.rtdxtutsim.dir = 'c6x'; 
            board.rtdxtut.projname = 'rtdxtutorial_67xe.pjt';
            board.rtdxtut.loadfile = 'rtdxtutorial_67xe.out';
            board.rtdxtut.Cbuildopt = '-g -as -me';
            board.rtdxtut.dir = 'c6x'; 
        case 'rtdxlmsdemo'
            board.rtdxdemosim.projname = 'rtdxdemo_sim67xe.pjt';
            board.rtdxdemosim.loadfile = 'rtdxdemo_sim67xe.out';
            board.rtdxdemosim.dir = 'c6x';
            board.rtdxdemosim.Cbuildopt = '-g -as -me';
            board.rtdxdemo.projname = 'rtdxdemo_67xe.pjt';
            board.rtdxdemo.loadfile = 'rtdxdemo_67xe.out';
            board.rtdxdemo.Cbuildopt = '-g -as -me';
            board.rtdxdemo.dir = 'c6x'; 
    end
    
elseif strcmpi(proc, 'c67x') && ~bigE,
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_67x.pjt';
            board.ccstut.loadfile = 'ccstut_67x.out';
            board.ccstut.Cbuildopt = '-g -as';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_67x.pjt';
            board.hiltut.loadfile = 'hiltut_67x.out';
            board.hiltut.Cbuildopt = '-g -as';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_67x.pjt';
            board.ccsfir.loadfile = 'a67x.out';
            board.ccsfir.Cbuildopt = '-g -as';
        case 'rtdxtutorial'
            board.rtdxtutsim.projname = 'rtdxtutorial_sim67x.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim67x.out';
            board.rtdxtutsim.Cbuildopt = '-g -as';
            board.rtdxtutsim.dir = 'c6x'; 
            board.rtdxtut.projname = 'rtdxtutorial_67x.pjt';
            board.rtdxtut.loadfile = 'rtdxtutorial_67x.out';
            board.rtdxtut.Cbuildopt = '-g -as';
            board.rtdxtut.dir = 'c6x'; 
        case 'rtdxlmsdemo'
            board.rtdxdemosim.projname = 'rtdxdemo_sim67x.pjt';
            board.rtdxdemosim.loadfile = 'rtdxdemo_sim67x.out';
            board.rtdxdemosim.dir = 'c6x';
            board.rtdxdemosim.Cbuildopt = '-g -as';
            board.rtdxdemo.projname = 'rtdxdemo_67x.pjt';
            board.rtdxdemo.loadfile = 'rtdxdemo_67x.out';
            board.rtdxdemo.Cbuildopt = '-g -as';
            board.rtdxdemo.dir = 'c6x'; 
    end
elseif strcmpi(proc, 'c64x') && bigE,
    switch(demoName)
        case 'ccstutorial'
            if isPrevCCSVer
            board.ccstut.projname = 'ccstut_64xe_ccs2p12.pjt';
            board.ccstut.loadfile = 'ccstut_64xe_ccs2p12.out';
            board.ccstut.Cbuildopt = '-g -as -me';
            else
            board.ccstut.projname = 'ccstut_64xe.pjt';
            board.ccstut.loadfile = 'ccstut_64xe.out';
            board.ccstut.Cbuildopt = '-g -as -me';
            end
        case 'hiltutorial' 
            if isPrevCCSVer
            board.hiltut.projname = 'hiltut_64xe_ccs2p12.pjt';
            board.hiltut.loadfile = 'hiltut_64xe_ccs2p12.out';
            board.hiltut.Cbuildopt = '-g -as -me';
            else
            board.hiltut.projname = 'hiltut_64xe.pjt';
            board.hiltut.loadfile = 'hiltut_64xe.out';
            board.hiltut.Cbuildopt = '-g -as -me';
            end
        case 'ccsfirdemo'
            if isPrevCCSVer
            board.ccsfir.projname = 'ccsfir_64xe_ccs2p12.pjt';
            board.ccsfir.loadfile = 'a64xe_ccs2p12.out';
            board.ccsfir.Cbuildopt = '-g -as -me';
            else
            board.ccsfir.projname = 'ccsfir_64xe.pjt';
            board.ccsfir.loadfile = 'a64xe.out';
            board.ccsfir.Cbuildopt = '-g -as -me';
            end
        case 'rtdxtutorial'
            if isPrevCCSVer
            board.rtdxtutsim.projname = 'rtdxtutorial_sim64xe_ccs2p12.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim64xe_ccs2p12.out';
            board.rtdxtutsim.Cbuildopt = '-g -as -me';
            board.rtdxtutsim.dir = 'c6x'; 
            else
            board.rtdxtutsim.projname = 'rtdxtutorial_sim64xe.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim64xe.out';
            board.rtdxtutsim.Cbuildopt = '-g -as -me';
            board.rtdxtutsim.dir = 'c6x'; 
            end
            board.rtdxtut.projname = 'rtdxtutorial_64xe.pjt';
            board.rtdxtut.loadfile = 'rtdxtutorial_64xe.out';
            board.rtdxtut.Cbuildopt = '-g -as -me';
            board.rtdxtut.dir = 'c6x'; 
        case 'rtdxlmsdemo'
            if isPrevCCSVer
            board.rtdxdemosim.projname = 'rtdxdemo_sim64xe_ccs2p12.pjt';
            board.rtdxdemosim.loadfile = 'rtdxdemo_sim64xe_ccs2p12.out';
            board.rtdxdemosim.dir = 'c6x';
            board.rtdxdemosim.Cbuildopt = '-g -as -me';
            else
            board.rtdxdemosim.projname = 'rtdxdemo_sim64xe.pjt';
            board.rtdxdemosim.loadfile = 'rtdxdemo_sim64xe.out';
            board.rtdxdemosim.dir = 'c6x';
            board.rtdxdemosim.Cbuildopt = '-g -as -me';
            end
            board.rtdxdemo.projname = 'rtdxdemo_64xe.pjt';
            board.rtdxdemo.loadfile = 'rtdxdemo_64xe.out';
            board.rtdxdemo.Cbuildopt = '-g -as -me';
            board.rtdxdemo.dir = 'c6x'; 
    end
    
elseif strcmpi(proc, 'c64x') && ~bigE,
    switch(demoName)
        case 'ccstutorial'
            if isPrevCCSVer
            board.ccstut.projname = 'ccstut_64x_ccs2p12.pjt';
            board.ccstut.loadfile = 'ccstut_64x_ccs2p12.out';
            board.ccstut.Cbuildopt = '-g -as';
            else
            board.ccstut.projname = 'ccstut_64x.pjt';
            board.ccstut.loadfile = 'ccstut_64x.out';
            board.ccstut.Cbuildopt = '-g -as';
            end
        case 'hiltutorial'      
            if isPrevCCSVer
            board.hiltut.projname = 'hiltut_64x_ccs2p12.pjt';
            board.hiltut.loadfile = 'hiltut_64x_ccs2p12.out';
            board.hiltut.Cbuildopt = '-g -as';
            else
            board.hiltut.projname = 'hiltut_64x.pjt';
            board.hiltut.loadfile = 'hiltut_64x.out';
            board.hiltut.Cbuildopt = '-g -as';
            end
        case 'ccsfirdemo'
            if isPrevCCSVer
            board.ccsfir.projname = 'ccsfir_64x_ccs2p12.pjt';
            board.ccsfir.loadfile = 'a64x_ccs2p12.out';
            board.ccsfir.Cbuildopt = '-g -as';
            else
            board.ccsfir.projname = 'ccsfir_64x.pjt';
            board.ccsfir.loadfile = 'a64x.out';
            board.ccsfir.Cbuildopt = '-g -as';
            end
        case 'rtdxtutorial'
            if isPrevCCSVer
            board.rtdxtutsim.projname = 'rtdxtutorial_sim64x_ccs2p12.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim64x_ccs2p12.out';
            board.rtdxtutsim.Cbuildopt = '-g -as';
            board.rtdxtutsim.dir = 'c6x'; 
            else
            board.rtdxtutsim.projname = 'rtdxtutorial_sim64x.pjt';
            board.rtdxtutsim.loadfile = 'rtdxtutorial_sim64x.out';
            board.rtdxtutsim.Cbuildopt = '-g -as';
            board.rtdxtutsim.dir = 'c6x'; 
            end
            board.rtdxtut.projname = 'rtdxtutorial_64x.pjt';
            board.rtdxtut.loadfile = 'rtdxtutorial_64x.out';
            board.rtdxtut.Cbuildopt = '-g -as';
            board.rtdxtut.dir = 'c6x'; 
        case 'rtdxlmsdemo'
            if isPrevCCSVer
            board.rtdxdemosim.projname = 'rtdxdemo_sim64x_ccs2p12.pjt';
            board.rtdxdemosim.loadfile = 'rtdxdemo_sim64x_ccs2p12.out';
            board.rtdxdemosim.dir = 'c6x';
            board.rtdxdemosim.Cbuildopt = '-g -as';
            else
            board.rtdxdemosim.projname = 'rtdxdemo_sim64x.pjt';
            board.rtdxdemosim.loadfile = 'rtdxdemo_sim64x.out';
            board.rtdxdemosim.dir = 'c6x';
            board.rtdxdemosim.Cbuildopt = '-g -as';
            end
            board.rtdxdemo.projname = 'rtdxdemo_64x.pjt';
            board.rtdxdemo.loadfile = 'rtdxdemo_64x.out';
            board.rtdxdemo.Cbuildopt = '-g -as';
            board.rtdxdemo.dir = 'c6x'; 
    end
   
elseif strcmpi(proc, 'r2x') && ~bigE,
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_r2x.pjt';
            board.ccstut.loadfile = 'ccstut_r2x.out';
            board.ccstut.Cbuildopt = '-g -as -me';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_r2x.pjt';
            board.hiltut.loadfile = 'hiltut_r2x.out';
            board.hiltut.Cbuildopt = '-g -as -me';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_r2x.pjt';
            board.ccsfir.loadfile = 'ar2x.out';
            board.ccsfir.Cbuildopt = '-g -as -me';
       case 'rtdxtutorial'
            board.rtdxtutsim = ''; %r2x does not support rtdx
            board.rtdxtut = '';
        case 'rtdxlmsdemo'
            board.rtdxdemosim = '';
            board.rtdxdemo = '';
    end
elseif strcmpi(proc, 'r2x') && bigE,
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_r2xe.pjt';
            board.ccstut.loadfile = 'ccstut_r2xe.out';
            board.ccstut.Cbuildopt = '-g -as';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_r2xe.pjt';
            board.hiltut.loadfile = 'hiltut_r2xe.out';
            board.hiltut.Cbuildopt = '-g -as';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_r2xe.pjt';
            board.ccsfir.loadfile = 'ar2xe.out';
            board.ccsfir.Cbuildopt = '-g -as';
        case 'rtdxtutorial'
            board.rtdxtutsim = ''; %r2x does not support rtdx
            board.rtdxtut = '';
        case 'rtdxlmsdemo'
            board.rtdxdemosim = '';
            board.rtdxdemo = '';
    end
elseif strcmpi(proc, 'r1x') && ~bigE,
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_r1x.pjt';
            board.ccstut.loadfile = 'ccstut_r1x.out';
            board.ccstut.Cbuildopt = '-g -as -me';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_r1x.pjt';
            board.hiltut.loadfile = 'hiltut_r1x.out';
            board.hiltut.Cbuildopt = '-g -as -me';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_r1x.pjt';
            board.ccsfir.loadfile = 'ar1x.out';
            board.ccsfir.Cbuildopt = '-g -as -me';
        case 'rtdxtutorial'
            board.rtdxtutsim = ''; %r1x does not support rtdx
            board.rtdxtut = '';
        case 'rtdxlmsdemo'
            board.rtdxdemosim = '';
            board.rtdxdemo = '';
    end
elseif strcmpi(proc, 'r1x') && bigE,
    switch(demoName)
        case 'ccstutorial'
            board.ccstut.projname = 'ccstut_r1xe.pjt';
            board.ccstut.loadfile = 'ccstut_r1xe.out';
            board.ccstut.Cbuildopt = '-g -as';
        case 'hiltutorial'      
            board.hiltut.projname = 'hiltut_r1xe.pjt';
            board.hiltut.loadfile = 'hiltut_r1xe.out';
            board.hiltut.Cbuildopt = '-g -as';
        case 'ccsfirdemo'
            board.ccsfir.projname = 'ccsfir_r1xe.pjt';
            board.ccsfir.loadfile = 'ar1xe.out';
            board.ccsfir.Cbuildopt = '-g -as';
        case 'rtdxtutorial'
            board.rtdxtutsim = ''; %r1x does not support rtdx
            board.rtdxtut = '';
        case 'rtdxlmsdemo'
            board.rtdxdemosim = '';
            board.rtdxdemo = '';
    end
end

% [EOF] GetDemoProp.m