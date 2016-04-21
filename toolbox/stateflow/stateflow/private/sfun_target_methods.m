function output = sfun_target_methods(method, targetId, varargin)
% output = sfun_target_methods(method, targetId, varargin)
% Target function for sfun targets.  See target_methods.m

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.5 $  $Date: 2004/04/15 01:00:22 $

output = feval(method,targetId,varargin{:});


function output = name(targetId,varargin)
    output = 'sfun';

		
function output = buildcommands(targetId,varargin)
    % return Nx3 cell array of <Menu string, Button string, method string>
    output = {...
        'Stateflow Target (incremental)',       'Build', 'sf_incremental_build';
        'Rebuild All (including libraries)',    'Rebuild All', 'sf_nonincremental_build';
        'Make without generating code',         'Make', 'sf_make';
        'Clean All (delete generated code/executables)','Clean All', 'sf_make_clean';
        'Clean Objects (delete executables only)', 'Clean Objects', 'sf_make_clean_objects';
    };

    if sf('Feature','Developer')
        output = [output; 
                {'Generate Code Only (non-incremental)'}, {'Generate'},{'sf_nonincremental_code'}];
    end


function output = targetproperties(targetId,varargin)
    % target_methods(targetId, 'targetproperties')
    output = {...
        'Custom code included at the top of generated code',      'target.customCode';
        'Custom include directory paths',                         'target.userIncludeDirs';
        'Custom source files',                                    'target.userSources';
        'Custom libraries',                                       'target.userLibraries';
        'Reserved Names',                                         'target.reservedNames';
        'Custom initialization code (called from mdlInitialize)', 'target.customInitializer';
        'Custom termination code (called from mdlTerminate)',     'target.customTerminator';
    };

function output = codeflags(targetId,varargin)
    persistent flags
    
    if(isempty(flags))
        flags = [];
        
        flag.name = 'debug';
        flag.type = 'boolean';
        flag.description = 'Enable debugging/animation';
        flag.defaultValue = 1;
        flags = [flags,flag];

        flag.name = 'overflow';
        flag.type = 'boolean';
        flag.description = 'Enable overflow detection (with debugging)';
        flag.defaultValue = 1;
        flags = [flags,flag];

        
        flag.name = 'echo';
        flag.type = 'boolean';
        flag.description = 'Echo expressions without semicolons';
        flag.defaultValue = 0;
        flags = [flags,flag];
        
        for i=1:length(flags)
            flags(i).visible = 'on';
            flags(i).enable = 'on';
        end
    end
    flags = target_code_flags('fill',targetId,flags);
    output = flags;

