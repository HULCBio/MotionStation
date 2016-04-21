function schema
% SCHEMA - define RTW.makertw class structure

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2004/04/15 00:24:01 $


%%%% Get handles of associated packages and classes
% Not derived from any other class
hCreateInPackage   = findpackage('RTW');
%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'makertw');

%%%% Add properties to this class
%% Following properties are initialized at ParseBuildArgs() method
hThisProp = schema.prop(hThisClass, 'ModelName', 'string');
% needs be double to correct store handle value
hThisProp = schema.prop(hThisClass, 'ModelHandle', 'double');
hThisProp = schema.prop(hThisClass, 'InitRTWOptsAndGenSettingsOnly', 'double');
hThisProp = schema.prop(hThisClass, 'BuildArgs', 'string');
hThisProp = schema.prop(hThisClass, 'DispHook', 'MATLAB array');
hThisProp = schema.prop(hThisClass, 'MdlRefBuildArgs', 'MATLAB array');
% ADA support has been removed, so languageDir is fixed to 'c'
%hThisProp = schema.prop(hThisClass, 'languageDir', 'string');
%hThisProp = schema.prop(hThisClass, 'adaEnvVar', 'string');

%%%% Add properties to this class
%% Following properties are initialized at CacheOriginalData() method
hThisProp = schema.prop(hThisClass, 'OrigDirtyFlag', 'string');
hThisProp = schema.prop(hThisClass, 'OrigStartTime', 'string');
hThisProp = schema.prop(hThisClass, 'OrigLockFlag', 'string');
%hThisProp = schema.prop(hThisClass, 'OrigRTWOptions', 'string');
%hThisProp = schema.prop(hThisClass, 'OrigRTWInlineParameters', 'string');

%% Following properties are initialized at PrepareAcceleratorAndSFunction() method
hThisProp = schema.prop(hThisClass, 'CodeReuse', 'double');

%% Following properties are initialized at GetSystemTargetFile() method
hThisProp = schema.prop(hThisClass, 'SystemTargetFilename', 'string');
hThisProp = schema.prop(hThisClass, 'SystemTargetFileId', 'double');
hThisProp = schema.prop(hThisClass, 'MakeRTWHookMFile', 'string');

%% Following properties are initialized at PrepareBuildArgs() method
hThisProp = schema.prop(hThisClass, 'BuildDirectory', 'string');
hThisProp = schema.prop(hThisClass, 'StartDirToRestore', 'string');
hThisProp = schema.prop(hThisClass, 'GeneratedTLCSubDir', 'string');
    %% Following properties are initialized at LocGetTMF() method
hThisProp = schema.prop(hThisClass, 'TemplateMakefile', 'string');
hThisProp = schema.prop(hThisClass, 'CompilerEnvVal', 'string');
    %% Following properties are initialized at getrtwroot() method
hThisProp = schema.prop(hThisClass, 'RTWRoot', 'string');

%% Following properties are initialized at CreateBuildOpts() method
hThisProp = schema.prop(hThisClass, 'BuildOpts', 'MATLAB array');

%% This property is used for mapping hardware specific data sizes to ANSI data
%% types
hThisProp = schema.prop(hThisClass, 'AnsiDataTypeTable', 'MATLAB array');

%% Certain compilers need additional info out of the mexopts.bat file, this
% property is used to pass it along
hThisProp = schema.prop(hThisClass, 'mexOpts', 'MATLAB array');

%% The control the file created for build log purpose
hThisProp = schema.prop(hThisClass, 'LogFileName', 'string');

%% The name of the active configuration set before the build process
%% and a flag indicating whether the old config set was overriden
hThisProp = schema.prop(hThisClass, 'OldConfigSetName', 'string');
hThisProp = schema.prop(hThisClass, 'OldConfigSetInactive', 'double');
