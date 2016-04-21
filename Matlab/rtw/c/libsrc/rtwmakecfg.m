function makeInfo=rtwmakecfg()
%RTWMAKECFG Add include and source directories to RTW make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following fields:
%
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be 
%                            expanded into include instructions of rtw 
%                            generated make files.
%     
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.
%
%     makeInfo.library     - structure containing additional runtime library
%                            names and module objects.  This information
%                            will be expanded into rules of rtw generated make
%                            files.

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.3.4.6 $ $Date: 2004/04/14 23:44:42 $

makeInfo.includePath = { fullfile(matlabroot,'rtw','c','libsrc') };
makeInfo.sourcePath  = { fullfile(matlabroot,'rtw','c','libsrc') };

arch = lower(computer);
if ispc, arch = 'win32'; end

modelName = get_param(0, 'CurrentSystem');
modules = '';
if ~isempty(modelName)
  buildArgs = get_param(modelName, 'RTWBuildArgs');
  sysTarget = get_param(modelName, 'RTWSystemTargetFile');
  bInteger = ~isempty(findstr(buildArgs, 'INTEGER_CODE=1'));
  bErt     = ~isempty(findstr(sysTarget, 'ert'));
  bRtwSfcn = ~isempty([findstr(sysTarget, 'rtwsfcn') findstr(sysTarget, 'accel')]);

  mdlRefSimTarget = get_param(modelName,'ModelReferenceTargetType');
  bRtwSfcn = strcmpi(mdlRefSimTarget, 'SIM') || bRtwSfcn;
  
  if ~bRtwSfcn
    simMode = get_param(modelName, 'SimulationMode');
    simStat = get_param(modelName, 'SimulationStatus');
    bRtwSfcn = strcmp(simStat, 'initializing') & strcmp(simMode, 'accelerator');
    if bRtwSfcn, disp('### Accelerator got you ;-)'); end
  end

  if bInteger
    modules = {'rt_enab','rt_sat_prod_int8','rt_sat_prod_int16', ...
	       'rt_sat_prod_int32','rt_sat_prod_uint8','rt_sat_prod_uint16', ...
	       'rt_sat_prod_uint32','rt_sat_div_int8','rt_sat_div_int16', ...
	       'rt_sat_div_int32','rt_sat_div_uint8','rt_sat_div_uint16', ...
	       'rt_sat_div_uint32'};
  else
    modules = extractfiles(fullfile(matlabroot,'rtw','c','libsrc'), '.c');

    if ~bRtwSfcn
      % Accelerator/S-function use rt_tdelayacc which requires utMalloc! */
      modules = modules(~strcmp(modules,'rt_tdelayacc'));
    end

    if bRtwSfcn
      modules = modules(~strcmp(modules, 'rt_matrx'));
    end
  end
end
  
makeInfo.precompile = 1;
makeInfo.library(1).Name     = 'rtwlib';
makeInfo.library(1).Location = fullfile(matlabroot,'rtw','c','lib', arch);
makeInfo.library(1).Modules  = modules;


% extractCfiles: local function to expand runtime source file list
function files=extractfiles(fileLocation, ext)
  dirstr=dir(fileLocation);
  files=[];
  len=length(ext);
  for i=1:length(dirstr)
    if (~dirstr(i).isdir)
      if strcmp(dirstr(i).name(end+1-len:end), ext)
	files = [files {dirstr(i).name(1:end-len)}];
      end
    end
  end
% [EOF] rtwmakecfg.m











