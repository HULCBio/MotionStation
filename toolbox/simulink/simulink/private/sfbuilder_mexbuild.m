function  [mexVerboseText, errorOccured] = sfbuilder_mexbuild(ad, sfunctionName , ...
                                                  userAlgorithm, varargin)
%SFBUILDER_MEXBUILD is a private function called by SFUNCTIONWIZARD to
% build the MEX FILE used by the S-Function builder.                                                                                        
                                                 
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/15 00:47:36 $                                               

% NOTES:
%
% 1. User libraries come in through the userAlgorithm string. These need to be
% separated as follows: 'lib1.c','lib3.obj','abc.lib' with the single quotes.
%
% 2. This function should get all the data that needs to be passed to the
% MEX commandline - file names, preprocessor definitions, include paths etc.
% Compiler specific work must ideally be done inside of this file, not outside.
%
% 3. VARARGIN input sequence:
% varargin{1} : additional include paths. Can be string (single
%               path) or cell array(list of paths). This is passed
%               to MEX with '-I' prepended.
% varargin{2} : preprocessor definitions. Can be string (single
%               definition) or cell array (multiple definition).
%               This list is prepended with '-D' and passed into
%               MEX.
%
% 4. The following method to add include paths should also work, though
% the method described in note 3 above is preferable:
% Type the following at the MATLAB prompt:
%  >>incPath = getappdata(0,'SfunctionBuilderIncludePath');
%  >>incPath{1} = <pathname>;
%  >>incPath{2} = getenv('NAME')
%   ....
%  >>setappdata(0,'SfunctionBuilderIncludePath',incPath)

% Initialization of variables
inport_num  = ad.SfunBuilderWidgets.getNumberofInputs;
outport_num = ad.SfunBuilderWidgets.getNumberofOutputs;
PortsHaveFixPtDataType = false;
mexVerboseText = '';
errorOccured = 0;
addLibsStr = userAlgorithm; 

addIncludePathStr = '';
if nargin > 3
  addIncludePaths = {};
  if ~isempty(varargin{1})
    numAddIncPaths = 0;
    if iscell(varargin{1})
      numAddIncPaths  = length(varargin{1});
      addIncludePaths = varargin{1};
    elseif ischar(varargin{1})
      numAddIncPaths  = 1;
      addIncludePaths = {varargin{1}};
    end
    for addIncIdx = 1:numAddIncPaths
      if isempty(addIncludePaths{addIncIdx}) continue; end
      addIncludePathStr = [addIncludePathStr '-I' '"' addIncludePaths{addIncIdx} '" '];
    end
    addIncludePathStr = ['''' addIncludePathStr ''''];
  end
end

addPreprocDefsStr = '';
if nargin > 4
  addPreprocDefs = {};
  if ~isempty(varargin{2})
    numPreprocDefs = 0;
    if iscell(varargin{2})
      numPreprocDefs = length(varargin{2});
      addPreprocDefs = varargin{2};
    elseif ischar(varargin{2})
      numPreprocDefs = 1;
      addPreprocDefs = {varargin{2}};
    end
    for addPreprocIdx = 1:numPreprocDefs
      if isempty(addPreprocDefs{addPreprocIdx}) continue; end
      addPreprocDefsStr = [addPreprocDefsStr '-D' addPreprocDefs{addPreprocIdx} ' '];
    end
    addPreprocDefsStr = ['''' addPreprocDefsStr ''''];
  end
end

% Check if Input Ports have fixed point data type
for k = 1:inport_num
  inPortsInfo.DataType{k} = char(ad.SfunBuilderWidgets.getInputPortDataType(k-1));
  if(strcmp(inPortsInfo.DataType{k},'fixpt'))
    PortsHaveFixPtDataType = true;
    break;
  end
end

if ~PortsHaveFixPtDataType
  for m = 1:outport_num
    outPortsInfo.DataType{m} = char(ad.SfunBuilderWidgets.getOutputPortDataType(m-1));
    if(strcmp(outPortsInfo.DataType{m},'fixpt'))
      PortsHaveFixPtDataType = true;
      break;
    end
  end
end

% Build S-function with appropriate library depending on platform and
% compiler
if PortsHaveFixPtDataType
  if isunix
    fixptlibstr = ['-L' matlabroot '/bin/' lower(computer)  ' -lfixedpoint'];
  else
    try
      compiler_info = slgetcompilerinfo;     % Gets compiler information
    catch
      errorOccured = 1;
      mexVerboseText = lasterr;
      return
    end       
    
    switch(compiler_info.compilerName)
     case 'lcc'
      fixptlibstr = [matlabroot, '\extern\lib\win32\lcc\libfixedpoint.lib'];
     case 'bc54'
      fixptlibstr = [matlabroot, '\extern\lib\win32\borland\bc54\libfixedpoint.lib'];
     case 'bc53'
      fixptlibstr = [matlabroot, '\extern\lib\win32\borland\bc53\libfixedpoint.lib'];
     case 'bc50'
      fixptlibstr = [matlabroot, '\extern\lib\win32\borland\bc50\libfixedpoint.lib'];
     case 'msvc50'
      fixptlibstr = [matlabroot, '\extern\lib\win32\microsoft\msvc50\libfixedpoint.lib'];
     case 'msvc60'
      fixptlibstr = [matlabroot, '\extern\lib\win32\microsoft\msvc60\libfixedpoint.lib'];
     case 'msvc70'
      fixptlibstr = [matlabroot, '\extern\lib\win32\microsoft\msvc70\libfixedpoint.lib'];
     case 'msvc71'
      fixptlibstr = [matlabroot, '\extern\lib\win32\microsoft\msvc71\libfixedpoint.lib'];

    end
  end

   addLibsStr = [addLibsStr  ',''' fixptlibstr ''''];

end

% Set as default so that the diagnostistcs shows the correct error message
IncludePath{1} = ['-I' filesep];
IncludePath{2} = ['-I' filesep];
IncludePath{3} = ['-I' filesep];
baseIncludePath = cell(1,3);

% get the application data quitely to avoid hard errors
try
  if isappdata(0,'SfunctionBuilderIncludePath')
    baseIncludePath = getappdata(0,'SfunctionBuilderIncludePath');
    if (iscell(baseIncludePath) & length(baseIncludePath) == 3)
      for k = 1:length(baseIncludePath)
        if ischar(baseIncludePath{k}) & ~isempty(baseIncludePath{k})
          IncludePath{k} = ['-I' baseIncludePath{k}];
        end
      end
    end
  end
end

IP1 = [IncludePath{1}];
IP2 = [IncludePath{2}];
IP3 = [IncludePath{3}];

IncludePath = [ ''''  IncludePath{1}  ''',''' IncludePath{2}   ''','''  IncludePath{3}  '''' ];

% Build command line
mexCommand = 'mex(';

% Verbosity
if(ad.SfunBuilderPanel.mexverboseButton.isSelected)
  mexCommand = [mexCommand '''-v'','];
end

% Debug build?
if(ad.SfunBuilderPanel.mexDebugFlagButton.isSelected)
  mexCommand = [mexCommand '''-g'','];
end

mexCommand = [mexCommand 'sfunctionName,' addLibsStr ',' IncludePath];

% Add additional include paths
if ~isempty(strtrim(addIncludePathStr))
  mexCommand = [mexCommand ',' addIncludePathStr];
end

% Add additional preprocessor definitions
if ~isempty(strtrim(addPreprocDefsStr))
  mexCommand = [mexCommand ',' addPreprocDefsStr];
end

mexCommand = [ mexCommand ')'];

mexDebugInfo = '';
if ~isempty(eval('DebugSFunctionBuilder;','[]'))
  mexDebugInfo = sprintf('MEX Command used: %s :\n',mexCommand);
end

[mexVerboseText, errorOccured] = evalc(mexCommand);
mexVerboseText = [mexDebugInfo mexVerboseText];