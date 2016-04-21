function list = getProjectFileList (h, modelName, sysTargetFile, type)

% $RCSfile: getProjectFileList.m,v $
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:06:07 $
% Copyright 2003-2004 The MathWorks, Inc.

IRmodelInfo  = getIRInfo_C2000DSP (modelName);

isGRTTarget = isequal (sysTargetFile, 'ti_c2000_grt.tlc');

if (isGRTTarget)
    names = { 'ti_nonfinite', 'rt_sim' };  
    extensions   = { '.c' '.c' };
else
    names = {};  
    extensions  = {};
end

rtwDefines = ti_RTWdefines ('get');
srcFilesList = rtwDefines.SourceFiles;

while ( ~isempty(srcFilesList) )
    [filename, srcFilesList] = strtok (srcFilesList);    
    [pathstr, name, ext, versn] = fileparts(filename);
    names = { names{:} name };
    extensions   = { extensions{:} ext };   
end

names = { names{:} 'DSP281x_CpuTimers' };   
extensions   = { extensions{:} '.c' };
if (IRmodelInfo.numADCs>0)
    names = { names{:} 'DSP281x_Adc' };   
    extensions   = { extensions{:} '.c' }; 
end
names = { names{:} 'DSP281x_DefaultIsr' };   
extensions   = { extensions{:} '.c' }; 
names = { names{:} 'DSP281x_GlobalVariableDefs' };   
extensions   = { extensions{:} '.c' }; 
names = { names{:} 'DSP281x_PieCtrl' };   
extensions   = { extensions{:} '.c' }; 
names = { names{:} 'DSP281x_PieVect' };   
extensions   = { extensions{:} '.c' }; 
names = { names{:} 'DSP281x_SysCtrl' };   
extensions   = { extensions{:} '.c' }; 
names = { names{:} 'DSP281x_usDelay' };   
extensions   = { extensions{:} '.asm' }; 

% XXX this might be needed in one of the future versions
% if isa(target_state.ccsObj.ccsversion,'ccs.CurrCCSVersion')
%     names = { names{:} 'DSP281x_Headers_nonBIOS' };   
%     extensions   = { extensions{:} '.cmd' }; 
% end

names = { names{:} 'MW_c28xx_csl' };   
extensions   = { extensions{:} '.c' }; 

if strmatch (type, 'source', 'exact'),
    list = '';
    for i=1:length(names),
        list = [list names{i} extensions{i} ' '];
    end
else % if type='object'
    ext = '.obj';
    list = {};
    for i=1:length(names),
        list = {list{:} [names{i} ext]};
    end
end
 
% [EOF] getProjectFileList.m
