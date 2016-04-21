function varargout = commblkeyescat2(block, action, varargin)
% COMMBLKEYESCAT2 Discrete-Time Eye Diagram/Scatter Plot/Signal Trajectory
% Scope dynamic dialog helping function

% See individual callback actions for functional descriptions. 
% NOTE: This file depends on setfieldindexnumbers.m and <sfunname>.m

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.7 $  $Date: 2002/05/11 17:06:53 $

sfunname = 'sdspfscope2';
%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************
switch(action)
%*********************************************************************
% Function Name:     Load
%
% Description:       Load callback function 
%
% Inputs:            Loads mask parameter into userdata to allow for
%                    error recovery.
%
% Return Values:     None
%********************************************************************
case 'Load',

    % We need to create the correct block string to call
    % Dialog Apply correctly in the init callback
    switch get_param(block,'block_type_'),
    case 'scatter',
		renderBlock = [block '/Scatter Rendering'];
    case 'eye',
		renderBlock = [block '/Eye Rendering'];
    case 'xy',
		renderBlock = [block '/X-Y Rendering'];
	end

    block_data.cparams.str = getMaskVarsAsStruct(block);
    set_param(renderBlock,'userdata',block_data);

%*********************************************************************
% Function Name:     init
%
% Description:       Main initialization code
%
% Inputs:            Used to verify the correct values of the mask and 
%                    update userdata. NOTE: calls DialogApply and 
%                    resetToFirstCall in sfunction. 
%
% Return Values:     None
%********************************************************************
case 'init',

    % --- Set Field index numbers and mask variable data
    setfieldindexnumbers(block);

    % --- Field data
    Vals = get_param(block, 'maskvalues');

    % We need to create the correct block string to call
    % resetToFirstCall and Dialog Apply
    switch get_param(block,'block_type_'),
    case 'scatter',
		renderBlock = [block '/Scatter Rendering'];
    case 'eye',
		renderBlock = [block '/Eye Rendering'];
    case 'xy',
		renderBlock = [block '/X-Y Rendering'];
	end

    % Get the block_data struct from userdata - from 'load' case
    %    set the old cparams from the exising cparams
    block_data = get_param(renderBlock,'userdata');
    block_data.params = getWorkspaceVarsAsStruct(renderBlock);
    if isfield(block_data,'cparams'),
        block_data.cparams_old = block_data.cparams;
    end
    block_data.cparams.str = getMaskVarsAsStruct(block);
    block_data.cparams.ws = getWorkspaceVarsAsStruct(block);
    set_param(renderBlock,'UserData',block_data);

    % Check and correct dialog errors
    feval(sfunname,[],[],[],'DialogApply', block_data.cparams.ws, renderBlock);

    % record final state of dialog -- after error recovery
    block_data.cparams.str = getMaskVarsAsStruct(block);
    block_data.cparams.ws = getWorkspaceVarsAsStruct(block);
    set_param(renderBlock,'UserData',block_data);

    try,
        if isfield(block_data,'comm') & isfield(block_data.comm,'numTraces') & ...
                    (block_data.comm.numTraces ~= block_data.cparams.ws.numTraces),
           feval(sfunname,[],[],[],'resetToFirstCall',renderBlock,1,1);              
        elseif hasRelevantParamChanged(block, block_data.cparams_old.str, block_data.cparams.str),
           feval(sfunname,[],[],[],'resetToFirstCall',renderBlock,1,0); 
        end
    catch,
        feval(sfunname,[],[],[],'resetToFirstCall',renderBlock);
    end



% --- End of case 'init'

case 'cbSetMaskVis',
    cbSetMaskVis(block);
    
case 'cbDispDiagram',
    cbDispDiagram(block);

% case 'cbDoNothing'

%*********************************************************************
% Function Name:    'default'
%
% Description:      Set the block defaults (development use only)
%
% Inputs:           current block
%
% Return Values:    none
%
%********************************************************************
case 'default',
    
	if nargin < 3,
        error('Enter ''eye'', ''scatter'',or ''xy'' for third argument with ''default'' action.');
	end
    commblkdef_eyescattraj(block,sfunname,mfilename);


%*********************************************************************
% Function Name:    show all
%
% Description:      Show all of the widgets
% Inputs:           current block
% Return Values:    none
% Notes:            This function is for development use only and allows
%                   All fields to be displayed
%********************************************************************
case 'showall',

    retDiagType = [];

    Vis = get_param(block, 'maskvisibilities');
    En  = get_param(block, 'maskenables');

    Cb = {};
    for n=1:length(Vis)
        Vis{n} = 'on';
        En{n} = 'on';
        Cb{n} = '';
    end;

    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En,'MaskCallbacks',Cb);

end

%*********************************************************************
% Function Name:    cbSetMaskVis
%
% Description:      Handle changes in the 'Plot Diagram' popup control
% Inputs:           current block
% Return Values:    none
%********************************************************************
function cbSetMaskVis(block)

    % --- Field data
    Vals = get_param(block, 'MaskValues');
    Vis  = get_param(block, 'MaskVisibilities');
    En   = get_param(block, 'MaskEnables');

    % --- Set the field index numbers
    setfieldindexnumbers(block);

    % --- Set the index lists for each page of the dialog according to
    %     block we are working with
    blocktype = Vals{idxBlock_type_};
    switch blocktype,
    case 'eye',
        idxPlot   = [idxSampPerSymb idxSymbPerTrace idxNumTraces idxOffsetEye idxNumNewFrames];
        idxRender = [idxLineMarkers idxLineColors idxRender idxFading idxLineStyles idxAxisGrid idxDupPoints];
        idxAxes   = [idxYMin idxYMax idxQuadratureLabel idxInphaseLabel];
        idxFig    = [idxDispDiagram idxOpenScopeAtSimStart idxFigPos idxFrameNumber idxFigTitle];
    case 'scatter'
        idxPlot   = [idxSampPerSymb idxNumTraces idxOffsetEye idxNumNewFrames];
        idxRender = [idxLineMarkers idxLineColors idxRender idxFading idxAxisGrid];
        idxAxes   = [idxXMax idxXMin idxYMin idxYMax idxQuadratureLabel idxInphaseLabel];
        idxFig    = [idxOpenScopeAtSimStart idxFigPos idxFrameNumber idxFigTitle];
    case 'xy'
        idxPlot   = [idxSampPerSymb idxNumTraces idxNumNewFrames];
        idxRender = [idxLineColors idxRender idxFading idxLineStyles idxAxisGrid];
        idxAxes   = [idxXMax idxXMin idxYMin idxYMax idxQuadratureLabel idxInphaseLabel];
        idxFig    = [idxOpenScopeAtSimStart idxFigPos idxFrameNumber idxFigTitle];
    otherwise,
		error(['Illegal value for Block type' ]);
    end

    % --- Update the Mask Parameters if the above switch statement resulted
    %     in new values for the Enable or visibility variables
	[Vis{idxPlot}]   = deal(Vals{idxShowPlotting});
	[Vis{idxRender}] = deal(Vals{idxShowRendering});
	[Vis{idxAxes}]   = deal(Vals{idxShowAxes});
	[Vis{idxFig}]    = deal(Vals{idxShowFigure});

    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);

%*********************************************************************
% Function Name:    cbDispDiagram
%
% Description:      Handle changes in the 'Plot Diagram' popup control.
%                   Used only for the Eye Diagram block.
% Inputs:           Current block
% Return Values:    None
%********************************************************************
function cbDispDiagram(thisBlock)

    % set up the choice matrix for enabling the vector scopes for I and Q components
    cmdIcheckbox = {'In-phase Only','on'; ...
                    'Quadrature-phase Only','off'; ...
                    'In-phase and Quadrature-phase','on'};
    cmdQcheckbox = {'In-phase Only','off'; ...
                    'Quadrature-phase Only','on'; ...
                    'In-phase and Quadrature-phase','on'};

% --------------------------------------------------------------------
function s = getWorkspaceVarsAsStruct(blk)
% Get mask workspace variables as a structure:

ss = get_param(blk,'maskwsvariables');
if isempty(ss),
    s = [];
    return
end

% Only the first "numdlg" variables are from dialog;
% others are created in the mask init fcn itself.
dlg = get_param(blk,'masknames');
numdlg = length(dlg);
ss = ss(1:numdlg);

% Create a structure with:
%   field names  = variable names
%   field values = variable values
s = cell2struct({ss.Value}',{ss.Name}',1);

% --------------------------------------------------------------------
function s = getMaskVarsAsStruct(blk)
% Get mask variable as a structure:

mnam = get_param(blk,'masknames');
mvals = get_param(blk,'maskvalues');
styles = get_param(blk,'maskstyles');

pv={};
r = get_param(blk,'maskvariables');
for i=1:length(styles), 
	[t,r]=strtok(r,'@&');
end
% Create a structure with:
%   field names  = variable names
%   field values = variable values
s = cell2struct(mvals,mnam);
% end of commblkeyescat2.m

% --------------------------------------------------------------------
function paramChanged = hasRelevantParamChanged(block, old_data, new_data)
% Determine if a relevant field has changed. 
setfieldindexnumbers(block);

paramChanged = 0;
param_names = fieldnames(old_data);
    
% Irrelevant parameters
paramIrrel = [idxOpenScopeAtSimStart];
%paramIrrel = [idxOpenScopeAtSimStart idxPropSelect idxFrameNumber];

for i=1:length(param_names),
    newParam = getfield(new_data,param_names{i});
    oldParam = getfield(old_data,param_names{i});
    
    if ~isempty(find(paramIrrel == i)),
        continue;
    end
  
    if ischar(newParam),
    	if ~strcmp(newParam,oldParam),
    		paramChanged = 1;
    		return;
    	end
    else        
    	if newParam ~= oldParam,
    		paramChanged = 1;
    		return;
    	end
    end
end
% end of commblkeyescat2.m
