function varargout = commblkalgintrlvr(block, action, varargin)
% COMMBLKALGINTRLVR Mask dynamic dialog function for Algebraic Interleaver & Deinterleaver blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/03/24 02:00:58 $


% --- Modes of operation
%		varargin{1} = action =	'init' - Indicates that the block initialization
%													function is calling the code.
%													The code should call the functions to update
%													visibilities/enables etc. and based on these
%													settings, make any changes to the
%													simulink block.
%
%						= action = 'update'-	Indicates that the code is being called
%													by the dynamic dialog update function.
%
%

% --- Field data

Vals	= get_param(block, 'maskvalues');
Vis		= get_param(block, 'maskvisibilities');
En  	= get_param(block, 'maskenables');

% --- Field numbers

IntrlvrType		= 1;
NumElements     = 2;
MultFactor      = 3;
CyclicShift     = 4;
PrimElem        = 5;

%
N      = eval(Vals{NumElements});
k      = eval(Vals{MultFactor});
h      = eval(Vals{CyclicShift});
alpha  = eval(Vals{PrimElem});


%*********************************************************************
% Function:			initialize
%
% Description:		Set the dialogs up based on the parameter values.
%						MaskEnables/MaskVisibles are not save in reference 
%						blocks.
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'init'))
    feval(mfilename,block,'UpdateFields');
    
        if(N ~= round(N))
            error('Number of elements must be an integer.');
        end
        
   if(strcmp(Vals{IntrlvrType},'Takeshita-Costello'))
        if(N ~= 2.0.^round(log(N)/log(2)))
            error('Number of elements must be a power of 2.');
        end
        if(mod(k,2) == 0)
            error('Multiplicative factor must be an odd integer.');
        end
        if(k<0)
            error('Multiplicative factor must be greater than zero.');
        end
        if(h ~= round(h))
            error('Cyclic shift must be an integer.');
        end
        if(h<0)
            error('Cyclic shift must be greater than or equal to zero.');
        end
        if(h>=N)
            error('Cyclic shift must be less than Number of elements.');
        end
        m = 0:N-1;
        c = rem((k*m.*(m+1)/2),N)+1;
        d = [c(2:end) c(1)];
        [u,v] = sort(c);
        y = d(v);
        if(h>0),
            y = [y(h+1:end) y(1:h)];
        end;
        varargout{1} = y;    
        
    elseif(strcmp(Vals{IntrlvrType},'Welch-Costas'))
        if ~isprime(N+1)
            error('Number of elements plus one must be prime.');
        end
        
        if alpha >= N
            error('Primitive element must be less than Number of elements.');
        end
        
        pf = factor(N);
        z = alpha*ones(size(pf)); 
        for n = 2:pf(end),
            z(n<=pf) = mod(z(n<=pf)*alpha,N+1);
        end
        
        for m = 1:2^length(pf)-2,
            sel = de2bi(m,length(pf));
            xpf = pf.*sel;
            xpf(xpf==0) = 1;
            xpp = prod(xpf);
            [mx, lx] = max(xpf);
            prd = 1;
            for n=1:xpp/mx,
                prd = mod(prd*z(lx),N+1);
            end
            if prd == 1,
                error('Specified value is not a primitive element.');
            end
        end
        
        y = zeros(1,N);
        y(1) = 1; 
        for i = 2:N, 
            y(i) = mod(y(i-1)*alpha,N+1);
        end       
        varargout{1} = y;    
    else
        error('Unrecognized mode');
    end;
end;

%----------------------------------------------------------------------
%
%	Block specific update functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function:			UpdateFields
%
% Description:		Update the dialog fields.
%						Indicate that block updates are not required
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'UpdateFields'))
    feval(mfilename,block,'Mode',1);
end;

%----------------------------------------------------------------------
%
%	Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'Mode'
%
% Description:		Deal with the mode of the operation
%
% Inputs:			current block
%						Update mode: Args = 0, block update required
%										 Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

IntrlvrType		= 1;
NumElements     = 2;
MultFactor      = 3;
CyclicShift     = 4;
PrimElem        = 5;

if(strcmp(action,'Mode'))
    
    if(strcmp(Vals{IntrlvrType},'Takeshita-Costello'))
        if(strcmp(Vis{MultFactor},'off'))
            
            % --- The Takeshita-Costello interleaver is selected and the Multiplicative factor
            %     field is not visible so this is a call requiring a change
            
            % --- Make visible and enable the Takeshita-Costello fields
            Vis{MultFactor}            = 'on';
            Vis{CyclicShift}  = 'on';
            
            En{MultFactor}             = 'on';
            En{CyclicShift}   = 'on';
            
            % --- Make invisible and disable the Welch-Costas field
            En{PrimElem}              = 'off';
            
            Vis{PrimElem}				  = 'off';
            
            set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
        end;
    elseif(strcmp(Vals{IntrlvrType},'Welch-Costas'))
        if(strcmp(Vis{PrimElem},'off'))
            
            % --- The Welch-Costas interleaver is selected and the Primitive element
            %     field is not visible so this is a call requiring a change
            
            % --- Make visible and enable the Welch-Costas field
            En{PrimElem}              = 'on';
            
            Vis{PrimElem}				  = 'on';
            
            % --- Make invisible and disable the Takeshita-Costello fields
            Vis{MultFactor}            = 'off';
            Vis{CyclicShift}  = 'off';
            
            En{MultFactor}             = 'off';
            En{CyclicShift}   = 'off';
            set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
        end;
    else
        error('Unrecognized mode');
    end;
end;


%----------------------------------------------------------------------
%
%	Setup/Utility functions
%
%----------------------------------------------------------------------


%*********************************************************************
% Function Name:	'default'
%
% Description:		Set the block defaults (development use only)
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************
if(strcmp(action,'default'))
    
    Cb{IntrlvrType}		= [mfilename '(gcb,''Mode'');'];
    Cb{NumElements}			= '';
    Cb{MultFactor}			= '';
    Cb{CyclicShift}			= '';
    Cb{PrimElem}		= '';
    
    En{IntrlvrType}				     = 'on';
    En{NumElements}				     = 'on';
    En{MultFactor}             = 'on';
    En{CyclicShift}		  = 'on';
    En{PrimElem}              = 'off';
    
    Vis{IntrlvrType}			     = 'on';
    Vis{NumElements}			     = 'on';
    Vis{MultFactor}            = 'on';
    Vis{CyclicShift}		  = 'on';
    Vis{PrimElem}				  = 'off';
    
    % --- Get the MaskTunableValues 
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{IntrlvrType}             = 'off';
    Tunable{NumElements}             = 'off';
    Tunable{MultFactor}           = 'off';
    Tunable{CyclicShift}     = 'off';
    Tunable{PrimElem}            = 'off';
    
    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);
    
    % --- Set the startup values.  '' Indicates that the default saved will be used
    
    Vals{IntrlvrType}		= 'Takeshita-Costello';
    Vals{NumElements}		= '256';
    Vals{MultFactor}        = '13';
    Vals{CyclicShift}	    = '0';
    Vals{PrimElem}          = '6';
    
    MN = get_param(gcb,'MaskNames');
    for n=1:length(Vals)
        if(~isempty(Vals{n}))
            set_param(block,MN{n},Vals{n});
        end;
    end;
    
    % --- Update the Vals field with the actual values
    
    Vals	= get_param(block, 'maskvalues');
    
    % --- Ensure that the block operates correctly from a library
    
    set_param(block,'MaskSelfModifiable','on');
    
end;


%*********************************************************************
% Function Name:	show all
%
% Description:		Show all of the widgets
%
% Inputs:			current block
%
% Return Values:	none
%
% Notes:				This function is for development use only and allows
%						All fields to be displayed
%
%********************************************************************

if(strcmp(action,'showall'))
    
    Vis	= get_param(block, 'maskvisibilities');
    En  	= get_param(block, 'maskenables');
    
    Cb = {};
    for n=1:length(Vis)
        Vis{n} = 'on';
        En{n} = 'on';
        Cb{n} = '';
    end;
    
    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En,'MaskCallbacks',Cb);
    
end;

