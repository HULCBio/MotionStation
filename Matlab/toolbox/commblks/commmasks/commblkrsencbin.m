function varargout = commblkrsencbin(block,action,varargin)
% COMMBLKRSENCBIN Communications Blockset Binary-Input Reed-Solomon Encoder block helper function.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:03:02 $

%  Possible calls:
%      commblkrsencbin(block, 'init');
%      commblkrsencbin(block, 'cbSpecPrimPoly');
%      commblkrsencbin(block, 'cbSpecGenPoly');

switch(action)

%*********************************************************************
% Function:      initialize
% Description:   Set the dialogs up based on the parameter values.
% Inputs:        current block
% Return Values: a MATLAB structure
%
%*********************************************************************
case 'init'

    % --- Set Field index numbers and mask variable data
    setallfieldvalues(block);

    % --- Ensure that the mask is correct 
    cbSpecPrimPoly(block);
    cbSpecGenPoly(block);

    % --- Field data
    Vals   = get_param(block, 'maskvalues');
    En     = get_param(block, 'maskenables');

    % --- Exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';
    
    params.m                = [];    % As in GF(2^m)
    
    % --- Check n and compute m
    [eStr params] = updateWorkSpace(block,params);    
    varargout{1} = eStr;
    varargout{2} = params;

case 'cbSpecPrimPoly'    
    cbSpecPrimPoly(block);

case 'cbSpecGenPoly'    
    cbSpecGenPoly(block);
    
otherwise
    error('Unknown action.');
end;


%*********************************************************************
% Function Name: 'cbSpecPrimPoly'
% Description     Deal with user-specified Primtive Polynomial
% Inputs:         current block
% Return Values:  none
%*********************************************************************
function cbSpecPrimPoly (block)  

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    En   = get_param(block, 'maskenables');
    
    % --- Set the field index numbers
    setfieldindexnumbers(block);

    prevEn = En{idxPrimPoly};
    
    switch Vals{idxSpecPrimPoly}
    case 'on'
        En{idxPrimPoly} = 'on';
    case 'off'
        En{idxPrimPoly} = 'off';
    otherwise
        error('Unknown specify primitive polynomial option.');
    end;
    
    if ( ~isequal(prevEn, En{idxPrimPoly}) )
      set_param(block,'MaskEnables',En);
      set_param([block '/RS Encoder'],'specPrimPoly',Vals{idxSpecPrimPoly});
    end

return;

%*********************************************************************
% Function Name: 'cbSpecGenPoly'
% Description     Deal with user-specified Generator Polynomial
% Inputs:         current block
% Return Values:  none
%*********************************************************************
function cbSpecGenPoly (block)  

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    En   = get_param(block, 'maskenables');
    
    % --- Set the field index numbers
    setfieldindexnumbers(block);

    prevEn = En{idxGenPoly};
    
    switch Vals{idxSpecGenPoly}
    case 'on'
        En{idxGenPoly} = 'on';
    case 'off'
        En{idxGenPoly} = 'off';
    otherwise
        error('Unknown specify generator polynomial option.');
    end;
    
    if ( ~isequal(prevEn, En{idxGenPoly}) )
      set_param(block,'MaskEnables',En);
      set_param([block '/RS Encoder'],'specGenPoly',Vals{idxSpecGenPoly});
    end

return;


% ------------------
% Helper functions
% ------------------

%*********************************************************************
% UPDATEWORKSPACE
% Checks mask parameters and computes params to pass to the S-fcn
%*********************************************************************
function [eStr,params] = updateWorkSpace(block,params)

    % --- Exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';
    
    % --- Set Field index numbers and mask variable data
    setallfieldvalues(block);

    Vals  = get_param(block, 'maskvalues');
    En    = get_param(block, 'maskenables');   

    % Basic checks for N 
    if ~isscalar(maskN) | floor(maskN)~=maskN 
        eStr.ecode = 1;
        eStr.emsg  = 'N must be an integer scalar. ';
        return;
    end

    % Compute m and t from N and K
    % Check N
    if maskN > 65535
        eStr.ecode = 1;
        eStr.emsg  = 'This block does not take any N larger than 2^16-1. ';
        return;
    end
    % Check K
    t = (maskN-maskK)/2;
    if floor(t) ~= t | t<1 | maskK < 1,
        eStr.ecode = 1;
        if maskK<1
            eStr.emsg  = 'K must be no less than 1.';
        else
            eStr.emsg  = 'N and K must differ by a positive even integer. ';
        end
        return;
    end
        
    % Check and establish relationship between primpoly and N
    %
    % Case I : specPrimPoly is on --
    %      primPoly must be of degree 3 or above
    %      m = degree of primPoly
    %      N cannot be larger than 2^m-1
    %
    % Case II : specPrimPoly is off --
    %      m = ceil(log2(N+1))
    %      m must be greater than 2 ==> N greater than 3
   
    % Get primPoly in decimal form
    if strcmp(En{idxPrimPoly},'on')
        
        % Dimension and datatype checks
        if ~strcmp(class(maskPrimPoly),'double') | ...
            ~( isvector(maskPrimPoly) && ~isempty(maskPrimPoly) && ...
            ~isscalar(maskPrimPoly) ) | size(maskPrimPoly,1)>size(maskPrimPoly,2)
            eStr.ecode = 1;
            eStr.emsg  = 'The Primitive Polynomial must be a row vector. ';
            return;
        end
        
        % Check primPoly - must be of degree 3 or above and irreducible over GF(2)
        
        % Check 1 - GF(2)
        if maskPrimPoly.*maskPrimPoly ~= maskPrimPoly
            eStr.ecode = 1;
            eStr.emsg  = 'The coefficients of the primitive polynomial must be binary. ';
            return;
        end
        
        % Checks 2 and 3 - irreducible and of degree 3 or above
        lasterr('');
        try
            evalc('primPolyRoots = roots(gf(maskPrimPoly,1));');
        catch
        end
        if ~isempty(lasterr) | ~isempty(primPolyRoots.x) | ...
            length(maskPrimPoly)-1 < 3 | length(maskPrimPoly)-1 > 16
            if length(maskPrimPoly)-1 > 16
                eStr.ecode = 1;
                eStr.emsg  = 'The primitive polynomial must not be of degree over 16. ';
                return;
            else
                eStr.ecode = 1;
                eStr.emsg  = 'The primitive polynomial must be of degree 3 or above. ';
                return;
            end
        end
        m = length(maskPrimPoly)-1;
        
        if maskN > 2^m-1
            eStr.ecode = 1;
            eStr.emsg  = 'N is too large for the primitive polynomial entered. ';
            return;
        end
        
        % Convert the binary coefficients (in descending order of powers) into a decimal number
        params.primPoly = bi2de(fliplr(maskPrimPoly));
    else
        p_vec = [1 7 11 19 37 67 137 285 529 1033 2053 4179 8219 17475 32771 69643];
        m  = ceil(log2(maskN+1));
        params.primPoly = p_vec(m);
        if m < 3,
            eStr.ecode = 1;
            eStr.emsg  = 'To use the default primitive polynomial, N must be greater than 3. ';
            return;
        end
   end
    
    params.m         = m;
                   
return;
    