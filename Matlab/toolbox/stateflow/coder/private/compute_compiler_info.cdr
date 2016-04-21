function compute_compiler_info

global gTargetInfo

compilerName = figure_out_the_required_compiler;
gTargetInfo.codingMSVC42Makefile    = 0;
gTargetInfo.codingMSVC50Makefile    = 0;
gTargetInfo.codingWatcomMakefile    = 0;
gTargetInfo.codingBorlandMakefile = 0;
gTargetInfo.codingLccMakefile       = 0;
gTargetInfo.codingUnixMakefile = 0;

if(~gTargetInfo.codingSFunction)
   return;
end

switch(compilerName)
    case 'msvc'
        gTargetInfo.codingMSVC42Makefile     = 1;
    case {'msvc50','msvc71'}
        gTargetInfo.codingMSVC50Makefile     = 1;
    case 'watcom'
        gTargetInfo.codingWatcomMakefile     = 1;
    case 'borland'
        gTargetInfo.codingBorlandMakefile = 1;
    case 'lcc'
        gTargetInfo.codingLccMakefile           = 1;
    case 'unix'
        gTargetInfo.codingUnixMakefile    = 1;
    otherwise
        % WISH internal error
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compilerName = figure_out_the_required_compiler

% first, check if you are running on Unix i.e, not running on pcwin
compilerName = '';
computerName = lower(computer);
if(~strcmp(computerName,'pcwin'))
    compilerName = 'unix';
    return;
end

compilerInfo = sf('Private','compilerman','get_compiler_info');
compilerName = compilerInfo.compilerName;
