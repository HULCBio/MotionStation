function varargout = RTWConfigurationCB(action,varargin)
%RTWConfigurationCB   Callback for the RTWConfiguration GUI
%
% varargout = RTWConfigurationCB( action, varargin )
%
% -- Arguments ---
%
%   action   - 'preloadfcn' |
%              'get_target' |
%              'get_target_subsystem' |
%              'get_target_from_system' |
%              'reset_config_target_block' |
%              'rtw_target_initfcn' |
%              'openfcn' |
%              'copyfcn' |
%              'NameChangeFcn' |
%              'presavefcn' |
%              'deletefcn' |
%              'closefcn' 
%
%   varargin - { block }

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.24.4.4 $
%   $Date: 2004/04/19 01:21:26 $

switch action
    
    case 'preloadfcn'
        % Required to load classes - no further action required 
    case 'get_target'
        % -- Get the RTWConfiguration.Target object closest above
        % in the Simulink heirarchy ---
        
        block = varargin{1};
        % get the closest target object
        target = i_getTarget(block);
        
        if ~isempty(target)
            %% we're done
            varargout = { target };
        else
            %% error
            i_missingTargetError(block);
        end;
    case 'get_target_subsystem'
        % similar to get_target, but returns the 
        % parent system of the closest target block
        block = varargin{1};
        [target, parent] = i_getTarget(block);
        
        if ~isempty(target)
            %% we're done
            varargout = { parent };
        else
            % error
            i_missingTargetError(block);
        end;
    case 'get_target_from_system'
        % call i_getTargetFindSystem (unlimited search depth)
        % to find a Resource Config block within the given system.
        % This case should be called from within the RT RTW hook file
        % it will handle the case when there are no RT driver blocks
        % in the system.    We must enforce that a Resource Configuration
        % block exists in the system for RT builds
        
        % searches for the target and returns it
        subsystem = varargin{1};
        % unlimited depth
        [target, errorCode] = i_getTargetFindSystem(subsystem);  
        
        switch (errorCode)
            case 'multiple_config_blocks'
                % error
                error(['Multiple Resource Configuration blocks were found in your model. '...
                       'Please remove duplicate Resource Configuration blocks from your model, '...
                       'and try to build again.']);                
            case 'config_block_not_found'
                % error
                error(['For this system target file, a single Resource Configuration block is required '...
                    'at the root level of the Simulink system you wish to '...
                    'generate code for.']);                 
            otherwise
                % no error    
                %% we're done
                varargout = { target };
        end;
    case 'reset_config_target_block'
       reset_config_target_block(varargin{1});
    case 'rtw_target_initfcn'


        % Find the configuration block that MUST live inside this
        % subystem. If it is not there throw an error.
        block = varargin{1};

        config_block = find_system(block,...
            'followlinks','on', ...
            'lookundermasks','on', ...
            'SearchDepth',1,...
            'tag','RTW CONFIGURATION BLOCK');
        if isempty(config_block)
            i_clean_parent(block);
        else
           % We wish the RC block to generate code ahead of all other
           % blocks in the model. By giving it the highest priority this
           % is achieved.

           set_param(config_block{1},'priority','-100000');
            
            % Update the config object. This may not be necessary
            % and could incur a speed penalty
            i_update_config(config_block{1});
            target = get_param(config_block{1},'userdata');
            
            
            % Place the target in the root of the model
            % in the TargetProperties field
            
            root = bdroot(block);
            set_param(root,'TargetProperties',target);
           
            % throw errors properly in a Simulink error message
            if ~isempty(target.errors)
               newln = sprintf('\n');
               error([newln '*** Resource Configuration Error ***' newln newln target.errors{:}]);
            end
        end
        
    case 'openfcn'
        block = varargin{1};
        if i_isInLibrary(block)
            % in library - do not allow block to open
            warndlg(['Please drag the resource configuration block into a model or model subsystem. ' ...
                    'The resource configuration block is not active in the ''' bdroot ''' drivers library'],...
                'Resource Configuration : Warning');
        else 
            i_update_config(block);
            target = get_param(block,'userdata');
            target.manageUI('create');
        end;
       
    case 'copyfcn'
        % -- The block has been copied ---

        block = varargin{1};
        if ~i_isInLibrary(block)
           block = varargin{1};
           i_copy_config_target_block(block);
           i_update_config(block);
        else
           reset_config_target_block(block)
        end
        
    case 'NameChangeFcn'
        % -- The block has been moved ---
        block = varargin{1};
        if ~i_isInLibrary(block)
           i_name_change_config_target_block(block);
           i_update_config(block);
        end
        
    case 'presavefcn'
        %-- Called when the model closes ---
        
        block = varargin{1};
        if ~i_isInLibrary(block)
            i_presave_config_target_block(block);
        end
        
    case 'deletefcn'
        block = varargin{1};
        % avoid error messages caused by the delete fcn 
        % being called when libraries close
        if ~i_isInLibrary(block)
            i_delete_config_target_block(block);
        end;
        
    case 'closefcn'
        block = varargin{1};
        target = get_param(block,'userdata');
        if ~isempty(target)
            target.closeUI;
        end
        
    otherwise
        error(sprintf('Invalid action: %s', action));
end

%% error message for missing target block
function i_missingTargetError(block)
rb = get_param(block, 'referenceblock');
rb_parent = get_param(rb,'parent');
rb_parent(rb_parent==sprintf('\n'))=' ';

error( [' Could not find a configuration block for ''' block '''. '  ...
        'Please place a configuration block from the same driver library ' ...
        'as ''' rb_parent ''' into your target subsystem. See ' ...
        'the documentation on using configuration blocks with ' ...
        'target subsystems. ']);
return;

% returns true if block is in a Simulink library
% returns false if block is not in a Simulink library
function inlibrary = i_isInLibrary(block)
    if (strcmp(get_param(bdroot(block),'BlockDiagramType'),'library'))
        inlibrary = true;
        return;
    else
        inlibrary = false;
        return;
    end;
return;

% implements the find_system for the target block,
% given a possible parent subsystem
% called by i_getTarget and 'get_target_from_subsystem' case
%
%   varargin{1} - optional extra argument is find_system search depth
%                 if this is omitted the search depth is unrestricted. 
%
%   possible errorCodes:
%   
%   no_error                    :   success
%   multiple_config_blocks      :   multiple config blocks were found
%   config_block_not_found      :   no config blocks were found
%
function [target, errorCode] = i_getTargetFindSystem(parent, varargin)
    target = [];
    errorCode = [];
    % check for depth argument
    if (nargin==2)
        depth = varargin{1};
        % apply search depth limit
        config_block = find_system(parent,...
            'FollowLinks','on',...
            'lookundermasks','on', ...
            'SearchDepth',depth,...           
            'tag','RTW CONFIGURATION BLOCK');
    else
        % no limit on search depth
        config_block = find_system(parent,...
                        'FollowLinks','on',...
                        'lookundermasks','on', ...
                        'tag','RTW CONFIGURATION BLOCK');
    end;
    %
    if ~isempty(config_block)
        if length(config_block) > 1
            % error - multiple config blocks were found
            errorCode = 'multiple_config_blocks';
            return;
        end;
        
        config_block = config_block{1};
        target = get_param(config_block,'userdata');
        if ~isa(target,'RTWConfiguration.Target')
            error([ 'The configuration block ' config_block ' is corrupted. ']);
        end
        errorCode = 'no_error';
    else
        % error - no config blocks were found
        errorCode = 'config_block_not_found';
    end;
return;

%% search for target block in the model
function [target, parent] = i_getTarget(block)
parent = get_param(block,'parent');
target = [];
while ~isempty(parent)
    % apply search depth == 1
    % not concerned with the error code here
    % since we are only searching to depth 1 then 
    % we will never hit the multiple config blocks case
    target = i_getTargetFindSystem(parent,1);
    if ~isempty(target)
        %% found a target
        %% return it
        return;
    end;
    parent = get_param(parent,'parent');
end
%% did not find a target - return empty objects
target = [];
parent = [];
return;

function i_presave_config_target_block(block)
% -- Close the model ---
% 
% I would like to raise the config GUI here but it seems
% that any java ui raised at this point cause MATLAB to
% freeze. I guess it is a thread problem ????
% 
target = get_param(block,'userdata');
if ~isempty(target)
    target.validate;
    % Remove the inactiveList
    target.inactiveList.disconnect;
end

function i_delete_config_target_block(block)
% -- Close the GUI if it is open
feval(mfilename, 'closefcn', block);


function i_copy_config_target_block(block)
% -- handle copying the configuration block from the library to the model --

% -- Arguments ---
%
%   block       -   The block which is being copied 

root = bdroot(block);
target = get_param(block,'userdata');
if ~isempty(target)
    % -- Perform a deep copy of the target ---
    fName = tempname;
    save(fName,'target');
    fileData = load(fName);
    target = fileData.target;
    target.block = block;
    set_param(block,'userdata',target);
end
i_init_parent_subsystem(block);

function i_name_change_config_target_block(block)
% -- handle copying the configuration block from the library to the model --

% -- Arguments ---
%
%   block       -   The block which is being copied 

root = bdroot(block);
switch get_param(root,'BlockDiagramType')
    
    case 'library'
        
        % -- Do nothing --
        
    otherwise
        
        % -- Initialize the new parent subsystem ---
        i_init_parent_subsystem(block);
        
end

function i_clean_parent(parent)
% -- Clean up the callbacks from an old parent subsystem ---
if ~isempty(parent)
    try
        oldinit = get_param(parent,'initfcn');
        set_param(parent,'initfcn',i_extract_old_block_fcn(oldinit));
        is_block_diagram = strcmp(get_param(parent,'type'),'block_diagram');
        if ~is_block_diagram
            % -- Remove the icon display command and preserve all others ---
            oldmask = get_param(parent,'MaskDisplay');
            idx = findstr(oldmask, [ c_create_config_mask_display sprintf('\n')]);
            if ~isempty(idx)
                oldmask = oldmask((idx + length(c_create_config_mask_display)) : end);
                set_param(parent,'MaskDisplay',i_extract_old_block_fcn(oldmask));
            end
        end
        
        % Remove model PreLoadFcn 
        model = bdroot(parent);
        
        config_block = find_system(model,...
            'FollowLinks','on',...
            'lookundermasks','on', ...         
            'tag','RTW CONFIGURATION BLOCK');
        
        if (length(config_block)==1)         
            % last config block is about to be deleted
            % so remove preLoadFcn from Model
            preLoadFcn = get_param(model, 'PreLoadFcn');
            while i_is_preloadfcn_already_set(preLoadFcn)
                preLoadFcn(1:length(c_create_config_model_preloadfcn)) = '';
            end
            set_param(model, 'PreLoadFcn', preLoadFcn);
        end
    catch
        % -- The parent may no longer exist during an ' undo - create subsystem '
    end
end

function i_init_parent_subsystem(block)
% -- Initialize the parent subsystem of a config block ---

parent = get_param(block,'parent');
initfcn = get_param(parent, 'initfcn');


if ~i_is_whitespace(initfcn) % | ~i_is_whitespace(maskdisplay)
    % -- There is already code is the parent callbacks and
    % it may not be our own ---
    
    if ~i_is_initfcn_installed(initfcn) 
        % The code in the callback is definately not our own
        % so we notify the user that modification will take place
        
        hilite_system(block);
        blockname = strrep(block,sprintf('\n'),' ');
        parentname = strrep(parent,sprintf('\n'),' ');
        str = strvcat('The block ', ...
            ' ', blockname , ' ', ...
            [ ' that you just copied needs to modify the ' ...
                '"initfcn" and the "MaskDisplay" of it''s parent subsystem ' ] , ...
            ' ', parentname , ' ' , ' Code will be pre-pended without affecting the ', ...
            'current functionality of the mask.');
        
        ButtonName=msgbox(str, ...
            'Copying Configuration Block');
    end
end

i_init_parent_subsystem_callbacks(parent);

% Set model PreLoadFcn
i_init_model(parent);

set_param(block,'oldParentName',parent);
set_param(block,'oldBlockName',block);



function ret = i_is_whitespace(str,type)
%-- Returns 1 if the string is empty or whitespace ---
% Parameters
%       str     -   The callback string to test
%       type    -   'initfcn' | 'maskdisplay'
% 
if isempty(str)
    ret = 1;
    return
end
if all(str == ' ' | str == sprintf('\n') | str == sprintf('\t'))
    ret = 1;
    return
end
ret = 0;
return


function ret = i_is_initfcn_installed(str)
%-- Returns 1 if the callback str is empty or whitespace or
% the callback is allready installed ----------------------
% 
% Parameters
%       str     -   The callback string to test

% 

if ~isempty(findstr(str, c_create_mask_start))
    ret = 1;
    return
end

ret = 0;



function i_init_parent_subsystem_callbacks(parent)
% -- Initialize the parent subsystem of the configuration block ---

% If the parent is a library link then the initialization functions
% will have allready been set and it should not be necessary to run
% any of the below. In fact it can cause Simulink to error out if
% a set_param is done on a library block

old_init_fcn = get_param(parent,'initfcn');


% -- Only make the changes if they have not been done before ---
if strcmp(get_param(parent,'type'),'block_diagram')
    
    if isempty(findstr(old_init_fcn, c_create_mask_start))
        % The is no previous RTW callback
        new_init_fcn = i_create_block_fcn(c_create_config_toplevel_initfcn, old_init_fcn);
        set_param(parent,'initfcn',new_init_fcn);
    end        
else
    
    if strcmp(get_param(parent,'linkstatus'),'resolved');
        return
    end
    
    old_mask_display = get_param(parent, 'maskdisplay');
    
    if isempty(findstr(old_init_fcn, c_create_mask_start))
        new_init_fcn = i_create_block_fcn(c_create_config_subsys_initfcn, old_init_fcn);
        set_param(parent,'initfcn',new_init_fcn);
    end
    
    if isempty(findstr(old_mask_display, c_create_config_mask_display))
        new_mask_display = ...
            [c_create_config_mask_display sprintf('\n') old_mask_display];
        set_param(parent,'MaskDisplay',new_mask_display );
        set_param(parent,'MaskIconOpaque','off');
    end
end



function init_fcn = i_extract_old_block_fcn(init_fcn)
% -- Remove the section of code from the initfcn that the config block requires ---
idx = findstr(init_fcn, c_create_mask_end);
if ~isempty(idx)
    % Remove the introduced code and the return character
    init_fcn = init_fcn((idx + length(c_create_mask_end) + 1) : end);
else
    % Do not modify the initfcn
end

function init_fcn = i_create_block_fcn(rtw_code,old_code)
% -- Merge the old and new init functions ---
n = sprintf('\n');
init_fcn = ...
    [c_create_mask_start n rtw_code n c_create_mask_end n old_code ];

function i_init_model(parent)
% -- Initialize the block diagram root of the configuration block ---

model = bdroot(parent);
preLoadFcn = get_param(model, 'PreLoadFcn');
if i_is_preloadfcn_already_set(preLoadFcn)
    % No action
else
    set_param(model, 'PreLoadFcn', [c_create_config_model_preloadfcn, preLoadFcn]);
end

function i_update_config(block)
% --- Update the configuration information. ---

% Get the current configuration object.
target = get_param(block,'userdata');
if isempty(target)
    target = RTWConfiguration.Target('new',block);
    set_param(block,'userdata',target);
end
target.block = block;
target.processModel;

function ret = i_is_initfcn_overwritable(initfcn)
% -- Return 1 if the mask initfcn is overwritable ---
if ((~isempty(initfcn)) & ...
        (~strcmp( c_create_config_subsys_initfcn, initfcn )) & ...
        (~strcmp( c_create_config_toplevel_initfcn, initfcn )))
    ret = 0;
else
    ret = 1;
end

function ret = i_is_preloadfcn_already_set(preLoadFcn)
% -- Return 1 if the preloadfcn already starts with correctPreLoadFcn ---
correctPreLoadFcn = c_create_config_model_preloadfcn;
if strncmp(preLoadFcn, correctPreLoadFcn, length(correctPreLoadFcn))
    ret = 1;
else
    ret = 0;
end

function reset_config_target_block(block)
        % Initialize the configuration block that lives under
        % the 'RTW Target' subsystem
        set_param(block,'userdatapersistent','on');
        target = RTWConfiguration.Target('new',block);
        set_param(block,'userdata',target);
        set_param(block,'openfcn','RTWConfigurationCB(''openfcn'',gcb);');
        set_param(block,'copyfcn','RTWConfigurationCB(''copyfcn'',gcb);');
        set_param(block,'deletefcn','RTWConfigurationCB(''deletefcn'',gcb);');
        set_param(block,'presavefcn','RTWConfigurationCB(''presavefcn'',gcb);');
        set_param(block,'NameChangeFcn','RTWConfigurationCB(''NameChangeFcn'',gcb);');
        set_param(block,'undodeletefcn','RTWConfigurationCB(''NameChangeFcn'',gcb);');
        
        set_param(block,'closefcn','');  % Closing the UI when the model closes fails
        set_param(block,'parentclosefcn','');
        
        set_param(block,'destroyfcn','');
        set_param(block,'postsavefcn','');
        set_param(block,'loadfcn','');
        


function cb = c_create_config_mask_display
% -- Create the MASK display for the subsystem containing the CONFIG block ---
cb = 'image(imread(''target_affordance_icon.jpg''),''bottom-right'')';

function cb = c_create_config_subsys_initfcn
% -- RTW_CONFIGURATION intfcn macro ---
cb = 'RTWConfigurationCB(''rtw_target_initfcn'',gcb);';

function cb = c_create_config_toplevel_initfcn
% -- RTW_CONFIGURATION InitFcn macro ---
cb = 'RTWConfigurationCB(''rtw_target_initfcn'',gcs);';

function cb = c_create_config_model_preloadfcn
% -- RTW_CONFIGURATION model PreLoadFcn macro ---
cb = 'RTWConfigurationCB(''preloadfcn'', bdroot);';

function cb = c_create_mask_start
% -- Start pattern to a code insertion ---
cb = '% START RTW CONFIGURATION CODE %';

function cb = c_create_mask_end
% -- END pattern to a code insertion ---
cb = '% END RTW CONFIGURATION CODE %';
