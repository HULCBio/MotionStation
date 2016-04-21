function output = default_target_methods(method, targetId, varargin)
% output = default_target_methods(method, targetId, varargin)
% Default target function for custom targets without an explicitly specified
% target function.  See target_methods.m.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $  $Date: 2004/04/15 00:56:43 $

output = feval(method,targetId,varargin{:});

function output = name(targetId,varargin)
    output = 'untitled';

function output = initialize(targetId,varargin)
	output = [];

function output = language(targetId,varargin)
    output = 'ANSI-C';

function output = preparse(targetId,varargin)
output = [];

function output = postparse(targetId,varargin)
output = [];

function output = precode(targetId,varargin)
output = [];

function output = postcode(targetId,varargin)
output = [];

function output = make(targetId,varargin)
output = [];

function output = machineheadertop(targetId,varargin)
	output = [];


function output = buildcommands(targetId,varargin)
    % return Nx3 cell array of <Menu string, Button string, method string>
    output = {...
        'Generate Code Only (non-incremental)', 'Generate', 'sf_nonincremental_code';
        'Rebuild All (including libraries)',    'Rebuild All', 'sf_nonincremental_build';
        'Make without generating code',         'Make', 'sf_make';
        'Clean All (delete generated code/executables)','Clean All', 'sf_make_clean';
        'Clean Objects (delete executables only)', 'Clean Objects', 'sf_make_clean_objects';
    };

function output = build(targetId,varargin)
	 output = [];
    buildMethod = varargin{1};
    
    machineId = sf('get',targetId,'target.machine');
    targetName = sf('get',targetId,'target.name');
    try,
        switch lower(buildMethod)
        case 'sf_incremental_build'
            autobuild_driver('build',machineId,targetName,'yes');
        case {'sf_nonincremental_build','sf_nonincremental_code'}
            autobuild_driver('rebuildall',machineId,targetName,'yes');
        case 'sf_make'
            autobuild_driver('make',machineId,targetName,'yes');
        case 'sf_make_clean'
            autobuild_driver('clean',machineId,targetName,'yes');
        case 'sf_make_clean_objects'
            autobuild_driver('clean_objects',machineId,targetName,'yes');                
        end
    catch,
    end


function output = targetproperties(targetId,varargin)
    output = {...
        'Custom code included at the top of generated code',      'target.customCode';
        'Custom include directory paths',                         'target.userIncludeDirs';
        'Custom source files',                                    'target.userSources';
        'Custom libraries',                                       'target.userLibraries';
        'Code Generation Directory',                              'target.codegenDirectory';
   	    'Reserved Names',                                         'target.reservedNames';
    };
	if sf('Feature','Target Function')
		output = [output;
                  {'Target Function','target.targetFunction'}];
    end
		  
function output = codeflags(targetId,varargin)
    % Return a structure array containing complete information on the options
    % supported by this target.    
    
    persistent flags
    
    if(isempty(flags))
        
        flag.name = 'comments';
        flag.type = 'boolean';
        flag.description = 'User Comments in generated code';
        flag.defaultValue = 1;
        flags = flag;

        flag.name = 'autocomments';
        flag.type = 'boolean';
        flag.description = 'Auto-generated Comments in generated code';
        flag.defaultValue = 0;
        flags(end+1) = flag;
        
        flag.name = 'emitdescriptions';
        flag.type = 'boolean';
        flag.description = 'State/Transition Descriptions in generated code';
        flag.defaultValue = 1;
        flags(end+1) = flag;
        
        flag.name = 'statebitsets';
        flag.type = 'boolean';
        flag.description = 'Use bitsets for storing state configuration';
        flag.defaultValue = 1;
        flags(end+1) = flag;
        
        flag.name = 'databitsets';
        flag.type = 'boolean';
        flag.description = 'Use bitsets for storing boolean data';
        flag.defaultValue = 1;
        flags(end+1) = flag;

        flag.name = 'emitlogicalops';
        flag.type = 'boolean';
        flag.description = 'Compact nested if-else using logical AND/OR operators';
        flag.defaultValue = 1;
        flags(end+1) = flag;
        
        flag.name = 'elseifdetection';
        flag.type = 'boolean';
        flag.description = 'Recognize if-elseif-else in nested if-else statements';
        flag.defaultValue = 1;
        flags(end+1) = flag;

        flag.name = 'constantfolding';
        flag.type = 'boolean';
        flag.description = 'Replace constant expressions by a single constant';
        flag.defaultValue = 1;
        flags(end+1) = flag;

        flag.name = 'redundantloadelimination';
        flag.type = 'boolean';
        flag.description = 'Minimize array reads using temporary variables';
        flag.defaultValue = 0;
        flags(end+1) = flag;
                
        flag.name = 'preservenames';
        flag.type = 'boolean';
        flag.description = 'Preserve symbol names';
        flag.defaultValue = 0;    
        flags(end+1) = flag;
        
        flag.name = 'preservenameswithparent';
        flag.type = 'boolean';
        flag.description = 'Append symbol names with parent names';
        flag.defaultValue = 0;
        flags(end+1) = flag;
        
        flag.name = 'exportcharts';
        flag.type = 'boolean';
        flag.description = 'Use chart names with no mangling';
        flag.defaultValue = 0;
        flags(end+1) = flag;
                
        flag.name = 'ioformat';
        flag.type = 'enumeration';
        flag.description = {'Use global input/output data',...
                'Pack input/output data into structures'};
        flag.defaultValue = 0;
        flags(end+1) = flag;
        
        flag.name = 'initializer';
        flag.type = 'boolean';
        flag.description = 'Generate chart initializer function';
        flag.defaultValue = 0;
        flags(end+1) = flag;
        
        flag.name = 'multiinstanced';
        flag.type = 'boolean';
        flag.description = 'Multi-instance capable code';
        flag.defaultValue = 0;
        flags(end+1) = flag;
        
        
        for i=1:length(flags)
            flags(i).visible = 'on';
            flags(i).enable = 'on';
        end
    end
    flags = target_code_flags('fill',targetId,flags);
    output = flags;
    
        

