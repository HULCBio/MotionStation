function [errStr, iconStr, cplxconstpts, t] = commblkqamtcmdec(block,action)
% COMMBLKQAMTCMDEC Mask function for Rectangular QAM TCM Decoder block
%
% Usage:
%      commblkqamtcmdec(block,'action');
%      where action corresponds to one of the following callbacks:
%      cbOpMode or init.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/07/30 02:48:32 $

% Default fcn: COMMBLKDEF_QAMTCMDEC

switch(action)
          
    case 'cbOpmode' % Callback for 'Operation Mode' parameter
        
        % -- Get mask idx for opmode parameter
        setfieldindexnumbers(block);
        
        % -- Get mask visibilities
        Vis	= get_param(block, 'maskVisibilities');
        
        if strcmp(get_param(block, 'opmode'),'Continuous'); 
            if strcmp(Vis{idxReset},'off')
                Vis{idxReset} = 'on';   
                
                % -- Set mask visibilities 
                set_param(block,'maskVisibilities', Vis);
            end
        else % Truncated and Terminated mode
            if strcmp(Vis{idxReset},'on')
                Vis{idxReset} = 'off';   
                                
                % -- Set mask visibilities and enables
                set_param(block,'maskVisibilities', Vis);
            end
        end
        
    case 'init'
               
        % -- Get mask values and enables
        En   = get_param(block, 'maskEnables');
        Vals = get_param(block, 'maskValues');
        
        % -- Get mask idx for Reset and Specchan parameter
        setallfieldvalues(block);

        %--  Draw icon
        % maskOpmode == 1 corresponds to 'Continuous' mode
        isRst  = maskReset==1 && strcmp(En{idxReset},'on') && maskOpmode==1;
        iconStr = drawIconFcn(isRst);
        Mnum = str2num(Vals{idxM});
                
        %-- Check parameters
        [cplxconstpts t errStr] = checkParamsTcmdec(block, Mnum);
        
end % switch-end case

%********************************************************************
function s = drawIconFcn(isRst)

% -- Drawing vectors for mask icon
s.draw.x = [10 30 10 30 10 NaN 10 30 10 30 10 NaN 30 50 30 50 30 NaN 30 50, ...
	30 50 30 NaN 50 70 50 70 50 NaN 50 70 50 70 50 NaN 70 90 70 90 70, ...
	NaN 70 90 70 90 70 NaN];
s.draw.y = [95 95 80 65 95 NaN 50 50 65 80 50 NaN 95 95 80 65 95 NaN 50 50, ...
	65 80 50 NaN 95 95 80 65 95 NaN 50 50 65 80 50 NaN 95 95 80 65 95, ...
	NaN 50 50 65 80 50 NaN];

% -- Setup inport label according to the number of ports
% Data port
p.i1=1; p.i1s='';
% Reset and Channel port
if isRst     
    p.i1=1; p.i1s=''; p.i2=2; p.i2s='Rst';
else
    p.i1=1; p.i1s='';  p.i2=1; p.i2s='';
end

% -- Setup outport label
p.o1 = 1; p.o1s = '';

% -- Store structure
s.ports = p;

%*********************************************************************
function [cplxconstpts, trellis, s] = checkParamsTcmdec(block, Mnum)

setallfieldvalues(block);

%-- Trellis check error message included in err
s.msg = [];
s.mmi = [];
cplxconstpts =[];

%--Check Trellis
[isok, msg] = istrellis(maskTrellis);
if(~isok)
    % Invalid trellis
    s.msg = ['Invalid trellis structure. ' msg]; 
    s.mmi = 'commblks:tcmconstmapper:isTrellis';
    trellis = [];
else
    % Define the trellis structure
    trellis.k          = log2(maskTrellis.numInputSymbols);
    trellis.n          = log2(maskTrellis.numOutputSymbols);
    trellis.numStates  = maskTrellis.numStates;
    trellis.outputs    = oct2dec(maskTrellis.outputs);
    trellis.nextStates = maskTrellis.nextStates;
    
    if(maskTrellis.numOutputSymbols~=Mnum)
        s.msg = ['Incorrect trellis specified for the chosen M-ary number.'];
        s.mmi = 'comm:commblkpsktcmdec:MTrellisDimension';
    else
        [cplxconstpts err] = tcmconstmapper(maskTrellis, Mnum, 'qam');
    end  
end

%-- Check Traceback depth: 
% Error out if empty, vector, negative or less than 1
if isempty(maskTbdepth) || ~isscalar(maskTbdepth) ||  ...
        ~isinteger(maskTbdepth) || maskTbdepth<1
    s.msg = 'Traceback depth must be a positive integer.';
    s.mmi = 'commblks:commblktcmdec:tbDepthCheck';
end

%[EOF]