function output = rtw_target_methods(method, targetId, varargin)
% output = rtw_target_methods(method, targetId, varargin)
% Target function for rtw targets.  See target_methods.m.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/15 00:59:13 $


output = feval(method,targetId,varargin{:});


function output = name(targetId,varargin)
    output = 'rtw';



function output = buildcommands(targetId,varargin)
    % return Nx3 cell array of <Menu string, Button string, method string>
    output = {...
        'Stateflow Target ',                    'Build', 'rtw_sfbuild';
    };
    machineId = sf('get',targetId,'target.machine');
    if ~sf('get',machineId,'machine.isLibrary')
        output = [ {'Real-Time Workshop build',    'RTW Build', 'rtw_build';
                    'Real-Time Workshop options',  'RTW Options', 'rtw_options'};
                   output ];
    end

function output = build(targetId,varargin)
    output = [];
    buildMethod = varargin{1};
    
    machineId = sf('get',targetId,'target.machine');
    targetName = sf('get',targetId,'target.name');
    modelH = sf('get',machineId,'.simulinkModel');
    
    
    try
        switch lower(buildMethod)
        case 'rtw_build'
            slsfnagctlr('Clear', get_param(modelH, 'name'), 'RTW Builder'); 
            try,
                simprm('RTWPage','Build',get_param(modelH,'Name'));
            catch,
            end
            slsfnagctlr('ViewNaglog');
            symbol_wiz('View', machine);
        case 'rtw_options'
            set_param(modelH, 'SimParamPage', 'RTW');
            set_param(modelH, 'SimulationCommand', 'SimParamDialog');
        case 'rtw_sfbuild'
        end
    catch
    end

function output = targetproperties(targetId,varargin)
    output = {...
        'Custom code included at the top of generated code',      'target.customCode';
        'Custom include directory paths',                         'target.userIncludeDirs';
        'Custom source files',                                    'target.userSources';
        'Reserved Names',                                         'target.reservedNames';
        'Custom initialization code (called from mdlInitialize)', 'target.customInitializer';
        'Custom termination code (called from mdlTerminate)',     'target.customTerminator';
    };

function output = codeflags(targetId,varargin)
    
    persistent flags
    
    if(isempty(flags))

        flag.name = 'comments';
        flag.type = 'boolean';
        flag.description = 'Comments in generated code';
        flag.defaultValue = 1;
        flags = flag;

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
        
        flag.name = 'preserveconstantnames';
        flag.type = 'boolean';
        flag.description = 'Preserve constant data names';
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
                
        for i=1:length(flags)
            flags(i).visible = 'on';
            flags(i).enable = 'on';
        end
    end
    flags = target_code_flags('fill',targetId,flags);
    output = flags;
    
    output = flags;   
 
