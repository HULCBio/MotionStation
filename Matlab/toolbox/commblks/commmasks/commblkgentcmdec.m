function [errStr, iconStr, cplxconstpts, t] = commblkgentcmdec(block,action)
% COMMBLKGENTCMDEC Mask function for General TCM Decoder block
%
% Usage:
%      commblkgentcmdec(block,'action');
%      where action corresponds to one of the following callbacks:
%      cbOpMode or init.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2003/12/01 18:59:31 $

% Default fcn: COMMBLKDEF_GENTCMDEC

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
        
        %-- Check parameters
        [cplxconstpts t errStr] = checkParamsTcmdec(block);       
       
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
function [cplxconstpts, trellis, s] = checkParamsTcmdec(block)

setallfieldvalues(block);

%-- Trellis check error message included in err
s.msg = [];
s.mmi = [];
cplxconstpts =[];
Mnum = numel(maskConstpts);

%--Check Trellis
[isok, msg] = istrellis(maskTrellis);
if(~isok)
    % Invalid trellis
    s.msg = ['Invalid trellis structure. ' msg]; 
    s.mmi = 'commblks:tcmconstmapper:isTrellis';
    trellis = [];
    return
end

% Define the trellis structure
trellis.k          = log2(maskTrellis.numInputSymbols);
trellis.n          = log2(maskTrellis.numOutputSymbols);
trellis.numStates  = maskTrellis.numStates;
trellis.outputs    = oct2dec(maskTrellis.outputs);
trellis.nextStates = maskTrellis.nextStates;


%-- Check constellation points: 
% Error out if empty, matrix, 1D vector, non-numeric or non-complex
if isempty(maskConstpts) || ismatrix(maskConstpts) || length(maskConstpts)<2 ...
        || ~isnumeric(maskConstpts) || (length(unique(maskConstpts)) ~= length(maskConstpts))
    s.msg = ['Signal constellation must be a vector of at least ' ...
            'two elements, representing the set of constellation points ' ...
            'that the modulator in the current model can generate.'];
    s.mmi = 'commblks:commblktcmdec:constPtsCheck';
    return
end

if(maskTrellis.numOutputSymbols~=Mnum)
  s.msg = ['Trellis specified does not correspond to the chosen signal constellation set.'];
  s.mmi = 'comm:commblkpsktcmdec:MTrellisDimension'; 
  return
end

constpts = gentcmconstmapper(maskTrellis, maskConstpts);                       
cplxconstpts = complex(real(constpts),imag(constpts)); 

%-- Check constellation points: 
% Error out if empty, matrix, 1D vector, non-numeric or non-complex
if isempty(cplxconstpts) || ismatrix(cplxconstpts) || length(cplxconstpts)<2 ...
        || ~isnumeric(cplxconstpts) || isreal(cplxconstpts) ...
        || (length(unique(cplxconstpts)) ~= length(cplxconstpts))
    s.msg = ['Signal constellation must be a vector of at least ' ...
            'two elements, representing the set of constellation points ' ...
            'that the modulator in the current model can generate.'];
    s.mmi = 'commblks:commblktcmdec:constPtsCheck';
    return
end

%-- Check Traceback depth: 
% Error out if empty, vector, negative or less than 1
if isempty(maskTbdepth) || ~isscalar(maskTbdepth) ||  ...
        ~isinteger(maskTbdepth) || maskTbdepth<1
    s.msg = 'Traceback depth must be a positive integer.';
    s.mmi = 'commblks:commblktcmdec:tbDepthCheck';
    return
end

%[EOF]