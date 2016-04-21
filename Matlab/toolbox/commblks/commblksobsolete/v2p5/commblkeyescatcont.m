function varargout = commblkeyescatcont(block, action, varargin)
% COMMBLKEYESCAT Eye/Scatter Scope dynamic dialog helping function
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:45:36 $


%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************
switch(action)
%*********************************************************************
% Function Name:     init
%
% Description:       Main initialization code
%
% Inputs:            current block and any parameters from the mask
%                    required for parameter calculation.
%
% Return Values:     params - Parameter structure
%********************************************************************
case 'init'

    % --- Initialize output parameters, exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';
    params = [];

    % --- Ensure that the mask is correct
    params.retDiagType = cbDiagram_type(block);

    % --- Return without error
    varargout{1} = eStr;
    varargout{2} = params;


% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbDiagram_type'
    params.retDiagType = cbDiagram_type(block);

%----------------------------------------------------------------------
%
%   Setup/Utility functions
%
%----------------------------------------------------------------------

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
case 'default'

    % --- Set Field index numbers and mask variable data
    setallfieldvalues(block);

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis  = get_param(block, 'maskvisibilities');
    En   = get_param(block, 'maskenables');

    Cb{idxTime_range} 		   	= '';
    Cb{idxTime_offset} 		   	= '';
    Cb{idxBoundary}			    = '';
    Cb{idxKept_length}			= '';
    Cb{idxDiagram_type}		    = [mfilename '(gcb,''cbDiagram_type'');'];
    Cb{idxEye_line}			    = '';
    Cb{idxScatter_line}		    = '';
    Cb{idxTwo_d_line}			= '';

    En{idxTime_range} 		   	= 'on';
    En{idxTime_offset} 		   	= 'on';
    En{idxBoundary}			    = 'on';
    En{idxKept_length}			= 'on';
    En{idxDiagram_type}		    = 'on';
    En{idxEye_line}			    = 'on';
    En{idxScatter_line}		    = 'off';
    En{idxTwo_d_line}			= 'off';

    Vis{idxTime_range} 		   	= 'on';
    Vis{idxTime_offset} 		= 'on';
    Vis{idxBoundary}			= 'on';
    Vis{idxKept_length}			= 'on';
    Vis{idxDiagram_type}		= 'on';
    Vis{idxEye_line}			= 'on';
    Vis{idxScatter_line}		= 'off';
    Vis{idxTwo_d_line}			= 'off';

    % --- Get the MaskTunableValues
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{idxTime_range} 		= 'off';
    Tunable{idxTime_offset} 	= 'off';
    Tunable{idxBoundary}		= 'off';
    Tunable{idxKept_length}		= 'off';
    Tunable{idxDiagram_type}	= 'off';
    Tunable{idxEye_line}		= 'off';
    Tunable{idxScatter_line}	= 'off';
    Tunable{idxTwo_d_line}		= 'off';

    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

    % --- Set the startup values.  '' Indicates that the default saved will be used
    Vals{idxTime_range} 	= '1';   
    Vals{idxTime_offset} 	= '0';   
    Vals{idxBoundary}		= '[-1.5 1.5]';
    Vals{idxKept_length}	= '5';
    Vals{idxDiagram_type}	= 'Eye Diagram';
    Vals{idxEye_line}		= 'b-/r-';
    Vals{idxScatter_line}	= 'b.';
    Vals{idxTwo_d_line}		= 'b-';

    % --- update Vals
    MN = get_param(block,'MaskNames');
    for n=1:length(Vals)
        if(~isempty(Vals{n}))
            set_param(block,MN{n},Vals{n});
        end;
    end;

    % --- Update the Vals field with the actual values
    Vals = get_param(block, 'maskvalues');

    % --- Ensure that the block operates correctly from a library
    set_param(block,'MaskSelfModifiable','on');


    % Set the return values for icon update
    params.retDiagType = Vals{idxDiagram_type};

%*********************************************************************
% Function Name:    show all
%
% Description:      Show all of the widgets
%
% Inputs:           current block
%
% Return Values:    none
%
% Notes:            This function is for development use only and allows
%                   All fields to be displayed
%
%********************************************************************
case 'showall'

    % calculate x and y for the icon update
    retDiagType = [];

    Vis = get_param(block, 'maskvisibilities');
    En      = get_param(block, 'maskenables');

    Cb = {};
    for n=1:length(Vis)
        Vis{n} = 'on';
        En{n} = 'on';
        Cb{n} = '';
    end;

    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En,'MaskCallbacks',Cb);

end

%----------------------------------------------------------------------
%
%   Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:    cbDiagram_type
%
% Description:      Handle changes in the 'Plot Diagram' popup control
%
% Inputs:           current block
%
% Return Values:    none
%
%********************************************************************
function retDiagType = cbDiagram_type(block)

    % --- Field data
    Vals = get_param(block, 'MaskValues');
    Vis  = get_param(block, 'MaskVisibilities');
    En   = get_param(block, 'MaskEnables');

    % --- Set the field index numbers
    setfieldindexnumbers(block);

    prevEn  = En([idxEye_line idxScatter_line idxTwo_d_line]);
    prevVis = Vis([idxEye_line idxScatter_line idxTwo_d_line]);

    retDiagType = Vals{idxDiagram_type};
	switch(retDiagType)
		case 'Eye Diagram'
            En{idxEye_line}		    = 'on';
            Vis{idxEye_line}		= 'on';
            En{idxScatter_line}	    = 'off';
            Vis{idxScatter_line}	= 'off';
            En{idxTwo_d_line}		= 'off';
            Vis{idxTwo_d_line}		= 'off';
		case 'Scatter Diagram'
            En{idxEye_line}		    = 'off';
            Vis{idxEye_line}		= 'off';
            En{idxScatter_line}	    = 'on';
            Vis{idxScatter_line}	= 'on';
            En{idxTwo_d_line}		= 'off';
            Vis{idxTwo_d_line}		= 'off';
		case 'Eye and Scatter Diagrams'
            En{idxEye_line}		    = 'on';
            Vis{idxEye_line}		= 'on';
            En{idxScatter_line}	    = 'on';
            Vis{idxScatter_line}	= 'on';
            En{idxTwo_d_line}		= 'off';
            Vis{idxTwo_d_line}		= 'off';
		case 'X-Y Diagram'
            En{idxEye_line}		    = 'off';
            Vis{idxEye_line}		= 'off';
            En{idxScatter_line}	    = 'off';
            Vis{idxScatter_line}	= 'off';
            En{idxTwo_d_line}		= 'on';
            Vis{idxTwo_d_line}		= 'on';
		case 'Eye and X-Y Diagrams'
            En{idxEye_line}		    = 'on';
            Vis{idxEye_line}		= 'on';
            En{idxScatter_line}	    = 'off';
            Vis{idxScatter_line}	= 'off';
            En{idxTwo_d_line}		= 'on';
            Vis{idxTwo_d_line}		= 'on';
		otherwise
			error('Illegal value for Diagram Type');
	end


   % Update the Mask Parameters if the above switch statement resulted 
   % in new values for the Enable or visibility variables
    if ( ~isequal(prevEn,  En([idxEye_line idxScatter_line idxTwo_d_line])) | ...
         ~isequal(prevVis, Vis([idxEye_line idxScatter_line idxTwo_d_line])) )
        set_param(block,'MaskEnables',En,'MaskVisibilities',Vis);
    end
