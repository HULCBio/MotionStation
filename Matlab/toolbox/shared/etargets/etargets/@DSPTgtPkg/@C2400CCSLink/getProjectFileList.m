function list = getProjectFileList (h, modelName, sysTargetFile, type)

% $RCSfile: getProjectFileList.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:53 $
% Copyright 2003-2004 The MathWorks, Inc.

isGRTTarget = isequal (sysTargetFile, 'ti_c2000_grt.tlc');

if (isGRTTarget)
    names = { 'ti_nonfinite' 'rt_sim' 'WD_disable' };  
    extensions   = { '.c' '.c' '.asm' };
else
    names = { 'WD_disable' };  
    extensions  = { '.asm' };
end

rtwDefines = ti_RTWdefines ('get');
srcFilesList = rtwDefines.SourceFiles;

while ( ~isempty(srcFilesList) )
    [filename, srcFilesList] = strtok (srcFilesList);    
    [pathstr, name, ext, versn] = fileparts(filename);
    names = { names{:} name };
    extensions   = { extensions{:} ext };
end

names = { names{:} 'DSP24_GlobalVariableDefs' };   
extensions   = { extensions{:} '.c' }; 

names = { names{:} 'vectors' };   
extensions   = { extensions{:} '.asm' }; 

names = { names{:} 'MW_c24xx_csl' };   
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
