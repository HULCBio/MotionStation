function varargout = sigbuilder_block(method,varargin)
% SIGBUILDER_BLOCK - Simulink management function
% for the STV block.

%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.19.4.10 $  $Date: 2004/04/15 00:49:06 $

if nargin==1 & strcmp(method,'clipboard')
    return;
end

switch(nargin)
case 1
    block = gcb;
    blockH = get_param(block,'Handle');
    modelH = bdroot(blockH);
case 2
end

switch(method)
case 'create'
    dialog = varargin{1};
    names = varargin{2};
    handleStruct = create(dialog,names,varargin{3:end});
    varargout{1} = handleStruct;

case 'open'
    figHandle = open_gui(varargin{:});
    
case 'newChannelCount'
    blockH = varargin{1};
    modelH = varargin{2};
    chCount = varargin{3};
    dispCmd = get_display_command(chCount);
    set_param(blockH, 'MaskDisplay', dispCmd);

case 'load'
    block = gcb;
    blockH = get_param(block,'Handle');
    modelH = bdroot(blockH);
    vnv_notify('sbBlkLoad',blockH);

    if (nargin>1)
        figHandle = open_gui(varargin{:});
    end

case 'close'
case 'modelClose'
    blockUD = get_param(blockH,'UserData');
    if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
        sigbuilder('close',blockUD);
    end

case 'delete'
    blockUD = get_param(blockH,'UserData');
    if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
        sigbuilder('close',blockUD);
    end
    vnv_notify('sbBlkDelete',blockH);

case 'destroy'
case 'preSave'
    blockUD = get_param(blockH,'UserData');
    if ~model_is_a_library(modelH)
        if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD) 
            sigbuilder('writeToSl',blockUD);
            if strcmp(get(blockUD,'visible'),'on')
                set_param(blockH,'LoadFcn',block_cmd_with_pos('load',blockUD));
            else
                set_param(blockH,'LoadFcn','sigbuilder_block(''load'');');
            end
        else
            if ~is_a_link(blockH)
                set_param(blockH,'LoadFcn','sigbuilder_block(''load'');');
            end
        end
    else
        if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD) 
            sigbuilder('writeToSl',blockUD);
        end
    end

case 'start'
    blockUD = get_param(blockH,'UserData');
    if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
        sigbuilder('sim_start',blockUD);
    end

case 'stop'
    blockUD = get_param(blockH,'UserData');
    if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
        sigbuilder('sim_stop',blockUD);
    end

case 'namechange'
    blockUD = get_param(blockH,'UserData');
    if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
        sigbuilder('slBlockRename',blockUD);
    end
    
case 'clipboard'
case 'maskInit'
    varargout{1} = sigbuilder('tuVar',blockH,modelH);
    
    % Put the fromWsH in the blocks UserData
    fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
    set_param(fromWsH,'UserData',fromWsH);
    
case 'copy'
    blockUD = get_param(blockH,'UserData');
    if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
        % If the editor is open for the source block
        % Flush its changes and copy the new SigBuilderData
        sigbuilder('writeToSl',blockUD);
        oldUD = get(blockUD,'UserData');
        oldFromWsH = oldUD.simulink.fromWsH;
        newfromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
        set_param(newfromWsH,'SigBuilderData',get_param(oldFromWsH,'SigBuilderData'));
    else
        % We may need to manually copy the SigBuilderData from the src block 
        % to the destination block.  This is possible because the old
        % block handle is stored in the UserData.
        newfromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
        oldFromWsH = get_param(newfromWsH,'UserData');
        UD = get_param(newfromWsH,'SigBuilderData');
        if isempty(UD) & ~isempty(oldFromWsH)
            set_param(newfromWsH,'SigBuilderData',get_param(oldFromWsH,'SigBuilderData'));
        end
    end
    refBlk = get_param(blockH, 'ReferenceBlock');
    linkStatus = get_param(blockH, 'LinkStatus');
    if ~isempty(refBlk) & ~strcmp(linkStatus,'implicit')
        if (strcmp(lower(bdroot(refBlk)),'simulink3') | strcmp(lower(bdroot(refBlk)),'simulink') | strcmp(lower(bdroot(refBlk)),'siglib'))
            set_param(blockH,'LinkStatus','none','MaskIconRotate','on');
        end
    end
    set_param(blockH,'UserData',[]);
    vnv_notify('sbBlkCopy',blockH);
    
case 'add_outport'
    hStruct = varargin{1};
    if nargin<4
        index = length(hStruct.outPortH)+1;
        portName = varargin{2};
    else
        index = varargin{2};
        portName = varargin{3};
    end
    hStruct = add_outport(hStruct,index,portName);
    varargout{1} = hStruct;
    
    
case 'delete_outport'
    hStruct = varargin{1};
    index = varargin{2};
    hStruct = delete_outport(hStruct,index);
    varargout{1} = hStruct;
    
    
case 'rename_outport'
    hStruct = varargin{1};
    index = varargin{2};
    portName = varargin{3};
    hStruct = rename_outport(hStruct,index,portName);
    varargout{1} = hStruct;
    
case 'move_port'
    hStruct = varargin{1};
    oldIndex = varargin{2};
    newIndex = varargin{3};
    hStruct = move_port(hStruct,oldIndex,newIndex);
    varargout{1} = hStruct;
    
case 'figClose'
    hStruct = varargin{1};
    dirtyFlag = get_param(hStruct.modelH,'dirty');
    figH = get_param(hStruct.subsysH, 'UserData');
    if ~isempty(figH) & figH>0 & ishandle(figH) & strcmp(get(figH,'visible'),'on')
        pos = get(figH,'Position');
        set_param(hStruct.subsysH,'OpenFcn',block_cmd_with_pos('open',figH));
        set_param(hStruct.modelH,'dirty',dirtyFlag);
    end
    

    if model_is_a_library(hStruct.modelH) & model_is_locked(hStruct.modelH)
        set_param(hStruct.modelH,'lock','off');
        set_param(hStruct.subsysH,'UserData',[]);
        set_param(hStruct.modelH,'lock','on');
    else
        set_param(hStruct.subsysH, 'UserData',[]);
    end

end


function figHandle = open_gui(varargin)

    if nargin>0
        guiPos = varargin{1};
    else
        guiPos = [];
    end
    
    block = gcb;
    model = bdroot(gcb);
    blockH = get_param(block,'Handle');
    modelH = get_param(model,'Handle');
    blockUD = get_param(block,'UserData');
    figHandle = [];
    
    % Error message if this is a locked library
    if (model_is_a_library(modelH) & model_is_locked(modelH))
        if (strcmp(lower(model),'simulink3') | strcmp(lower(model),'simulink') | strcmp(lower(bdroot(refBlk)),'siglib'))
            errordlg(['To edit signal data, first place this block in a model. ']);
        else
            errordlg(['To view or edit signal data, unlock the library .']);
        end
        return;
    end
    
    % Look under the mask to build up the handle structure
    handleStruct.subsysH = blockH;
    handleStruct.modelH = modelH;
    handleStruct.fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
    handleStruct.demuxH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','Demux');
    outports = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','Outport');

    % Put the outports in order
    portNums = get_param(outports,'Port');
    if iscell(portNums)
        portNums = str2num(strvcat(portNums{:}));
        [y,sortIdx] = sort(portNums);
        handleStruct.outPortH = outports(sortIdx);
    else
        handleStruct.outPortH = outports;
    end

    if is_a_link(blockH)
        errordlg(['You can only edit the signal data for a linked block by', ...
                 ' opening the editor from the source block in the library.']);
    else

        if ~isempty(blockUD) & blockUD>0 & ishandle(blockUD)
            if strcmp(get(blockUD,'Visible'),'off')
                set(blockUD,'Visible','on');
            end
            figure(blockUD);
            figHandle = blockUD;
            return;
        else
            
            figHandle = sigbuilder('SlBlockOpen',handleStruct,[]);
            if model_is_a_library(modelH) & model_is_locked(modelH)
                set_param(modelH,'lock','off');
                set_param(blockH,'UserData',figHandle);
                set_param(modelH,'lock','on');
            else
                set_param(blockH,'UserData',figHandle);
            end
        end
    end

    if ~isempty(guiPos)
        % Make sure the position is entirely within the screen extent]
        screenUnits = get(0,'Units');
        set(0,'Units','Points');
        screenPos = get(0,'ScreenSize');
        set(0,'Units',screenUnits);
    
        if (guiPos(1) + guiPos(3)) > screenPos(3)
            guiPos(1) = max(0,screenPos(3)-guiPos(3));
            guiPos(3) = min(guiPos(3),screenPos(3));
        end
        
        if (guiPos(2) + guiPos(4)) > screenPos(4)
            guiPos(2) = max(0,screenPos(4)-guiPos(4));
            guiPos(4) = min(guiPos(4),screenPos(4));
        end
    
        set(figHandle,'Position',guiPos);
    end
    set(figHandle,'Visible','on');

function cmdStr = block_cmd_with_pos(command,dialogH)

    try
        pos = get(dialogH,'Position');
        posStr = ['[' sprintf('%g ',pos) ']'];
        cmdStr = ['sigbuilder_block(''' command ''',' posStr ');'];
    catch
        cmdStr = ['sigbuilder_block(''' command ''');'];
    end




function handleStruct = create(dialog,nameCell,blckPath,blckPos)

    if nargin<4
        blckPos = [25 20 100 60];
    end
    
    if nargin<3
        modelH = new_system;
        model = get_param(modelH,'Name');
        blckPath = [model '/Signal Builder'];
    else
        modelH = get_param(strtok(blckPath,'/'),'Handle');
    end
    
    dispCmd = [ 'plot(0,0,100,100,[10,10,40,40,10],' ...
                '[80,20,20,80,80],[40,10],[50,50], ' ...
                '[40,27,10],[65,72,56],[40,25,25,10],[28,28,43,43]);'];
                
    subsysH =  add_block('built-in/Subsystem',          blckPath, ...
                        'UserData',                     dialog, ...  
                        'Position',                     blckPos, ...  
                        'MaskDisplay',                  dispCmd, ...  
                        'MaskIconOpaque',               'off', ...  
                        'Tag',                          'STV Subsys' ...  
                        );

    set_param(subsysH,'CopyFcn','sigbuilder_block(''copy'');');


    fromWsH = add_block('built-in/FromWorkspace',           [blckPath '/FromWs'], ...
                        'Position',                     [30 300 115 350], ...  
                        'Tag',                          'STV FromWs', ...  
                        'SampleTime',                   '0', ...    
                        'VariableName',                 'tuvar');   
    
    set_param( fromWsH, 'UserData',fromWsH);                                                             

    demuxH = add_block('built-in/Demux',                [blckPath '/Demux'], ...
                        'Position',                     [150 30 160 600], ...  
                        'Tag',                          'STV Demux', ...  
                        'Outputs',                      num2str(length(nameCell)));
    
    add_line(blckPath, 'FromWs/1', 'Demux/1');
    

    for i=1:length(nameCell)
        outPortH(i) = add_block(    'built-in/Outport',       [blckPath '/' nameCell{i}], ...
                                    'Position',                     [280 30*i 300 30*i+10], ...  
                                    'Tag',                          'STV Outport', ...  
                                    'Port',                         num2str(i));

        add_line(blckPath,  ['Demux/' num2str(i)], [nameCell{i} '/1']);
    end
    
    handleStruct.modelH = modelH;
    handleStruct.subsysH = subsysH;
    handleStruct.fromWsH = fromWsH;
    handleStruct.demuxH = demuxH;
    handleStruct.outPortH = outPortH;

    open_system(modelH);
    
    set_param(subsysH , ...
                        'OpenFcn',                      'sigbuilder_block(''open'');', ...  
                        'LoadFcn',                      'sigbuilder_block(''load'');', ...  
                        'CloseFcn',                     'sigbuilder_block(''close'');', ...  
                        'DeleteFcn',                    'sigbuilder_block(''delete'');', ...  
                        'ModelCloseFcn',                'sigbuilder_block(''modelClose'');', ...  
                        'PreSaveFcn',                   'sigbuilder_block(''preSave'');', ...  
                        'StartFcn',                     'sigbuilder_block(''start'');', ...  
                        'StopFcn',                      'sigbuilder_block(''stop'');', ...  
                        'NameChangeFcn',                'sigbuilder_block(''namechange'');', ...  
                        'ClipboardFcn',                 'sigbuilder_block(''clipboard'');', ...  
                        'MaskIconRotate',               'on', ...  
                        'MaskInitialization',           'if ~strcmp(get_param(bdroot(gcb),''SimulationStatus''),''stopped'') tuvar = sigbuilder_block(''maskInit''); end'); 
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLink = is_a_link(blockH),
%
% Determine if a block is a link
%
if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else,
   isLink = 1;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_is_a_library(modelH),
%
%  
%
    if strcmp(lower(get_param(modelH,'BlockDiagramType')),'library'), result = 1;
    else, result = 0;
    end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_is_locked(modelH),
%
%  
%
    result = strcmp(lower(get_param(modelH, 'lock')), 'on');




function hStruct = delete_outport(hStruct,index)
% Delete a single outport and rewire the existing
% outports without deletion

    % Remove internal lines
    origCnt = length(hStruct.outPortH);
    for i=index:origCnt
        remove_out_line(hStruct.demuxH,i);
    end
    
    delete_block(hStruct.outPortH(index));
    hStruct.outPortH(index) = [];
    
    set_param(hStruct.demuxH,'Outputs',num2str(origCnt-1));

    for i=index:(origCnt-1)
        addline(hStruct.demuxH,i,hStruct.outPortH(i),1);
    end

    position_ports(hStruct);

        % Manage the IOSignals for siggens
        type = get_param(hStruct.subsysH,'IOType');
        if (strcmp(type,'siggen')),
          sigs = get_param(hStruct.subsysH,'IOSignals');
          new_sigs = cell(length(sigs)-1,1);
          for i=1:index-1
            new_sigs{i} = sigs{i};
          end
          for i=index:length(new_sigs)
            new_sigs{i} = sigs{i+1};
          end
          set_param(hStruct.subsysH,'IOSignals',new_sigs);
        end;


function hStruct = add_outport(hStruct,index,name)

    % 
    % Remove internal lines
    origCnt = length(hStruct.outPortH);
    for i=index:origCnt
        remove_out_line(hStruct.demuxH,i);
    end
    
    set_param(hStruct.demuxH,'Outputs',num2str(origCnt+1));
    sysName = getfullname(hStruct.subsysH);
    
    % Move the outputs that change index as a block
    hStruct.outPortH((index:end)+1) = hStruct.outPortH(index:end);
        
    hStruct.outPortH(index) = add_block( ...
            'built-in/Outport', [sysName '/' name], ...
            'Position',         [320 30 340 40], ...  
            'Tag',              'STV Outport', ...  
            'Port',             num2str(index));

    for i=index:(origCnt+1)
        addline(hStruct.demuxH,i,hStruct.outPortH(i),1);
    end

    position_ports(hStruct);

        % Manage the IOSignals for siggens
        type = get_param(hStruct.subsysH,'IOType');
        if (strcmp(type,'siggen')),
          sigs = get_param(hStruct.subsysH,'IOSignals');
          new_sigs = cell(length(sigs)+1,1);
          for i=1:index-1
            new_sigs{i} = sigs{i};
          end
          new_sigs{index} = struct('Handle',-1,'RelativePath','');
          for i=index:length(sigs)
            new_sigs{i+1} = sigs{i};
          end
          set_param(hStruct.subsysH,'IOSignals',new_sigs);
        end;
    

function hStruct = rename_outport(hStruct,index,name)
    set_param(hStruct.outPortH(index),'Name',name);
    
        % Manage the IOSignals for siggens
        type = get_param(hStruct.subsysH,'IOType');
        if (strcmp(type,'siggen')),
          sigs = get_param(hStruct.subsysH,'IOSignals');
          set_param(hStruct.subsysH,'IOSignals',sigs);
        end;


function hStruct = move_port(hStruct,oldIdx,newIdx)

    % Remove internal lines
    portCnt = length(hStruct.outPortH);
    for i=1:portCnt
        remove_out_line(hStruct.demuxH,i);
    end

    if oldIdx>newIdx
        old2newIdx = [1:(newIdx-1) (newIdx+1):oldIdx newIdx (oldIdx+1):portCnt];
%       old2newIdx = [1:(newIdx-1) oldIdx  (newIdx+1):(oldIdx-1) newIdx (oldIdx+1):portCnt];
    else
        old2newIdx = [1:(oldIdx-1) newIdx  oldIdx:(newIdx-1) (newIdx+1):portCnt];
%       old2newIdx = [1:(oldIdx-1) newIdx  (oldIdx+1):(newIdx-1) oldIdx (newIdx+1):portCnt];
    end

    hStruct.outPortH = hStruct.outPortH(old2newIdx);

    for i=1:portCnt
        addline(hStruct.demuxH,i,hStruct.outPortH(i),1);
    end

    number_ports(hStruct)
    position_ports(hStruct);

        % Manage the IOSignals for siggens
        type = get_param(hStruct.subsysH,'IOType');
        if (strcmp(type,'siggen')),
          sigs = get_param(hStruct.subsysH,'IOSignals');
          temp = sigs{oldIdx};
          sigs{oldIdx} = sigs{newIdx};
          sigs{newIdx} = temp;
          set_param(hStruct.subsysH,'IOSignals',sigs);
        end;


function position_ports(hStruct)
    for i=1:length(hStruct.outPortH)
        set_param(hStruct.outPortH(i),'Position',[280 30*i 300 30*i+10]);
    end

function number_ports(hStruct)
    for i=1:length(hStruct.outPortH)
        set_param(hStruct.outPortH(i),'Port',num2str(i));
    end


function remove_out_line(blockH,index)

    portHandles = get_param(blockH,'PortHandles');
    thisPort = portHandles.Outport(index);
    try
        hL = get_param(thisPort,'Line');
        delete_line(hL);
    catch
    end



function remove_in_line(blockH,index)

    portHandles = get_param(blockH,'PortHandles');
    thisPort = portHandles.Inport(index);
    try
        hL = get_param(thisPort,'Line');
        delete_line(hL);
    catch
    end

function addline(srcH,srcIdx,dstH,dstIdx);

    add_line(   get_param(srcH,'Parent'), ...
                [get_param(srcH,'Name') '/' num2str(srcIdx)], ...
                [get_param(dstH,'Name') '/' num2str(dstIdx)]);
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notify the verification manager if it exists
function vnv_notify(method, blockH)

    if is_a_link(blockH) || ~(exist('vnv_assert_mgr')==2 || exist('vnv_assert_mgr')==6)
        return;
    end
    
    preverr = lasterr;
    
    try
        vnv_assert_mgr(method, blockH);
    catch
        % Restore the error state
        lasterr(preverr);
    end



