function [errStr, iconStr, cplxconstpts] = commblkmlseeq(block,action)
% COMMBLKMLSEEQ Mask function for MLSE Equalizer block for
% parameter checking
%
% Usage:
%      commblkmlseeq(block,'action');
%      where action corresponds to one of the following callbacks:
%      cbSpecchan, cbOpMode, cbPreamble, cbPostamble or init.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2003/06/23 04:36:40 $

% Default fcn: COMMBLKDEF_MLSEEQ

switch(action)
    
    case 'cbSpecchan' % Callback for 'Specify channel via' parameter
        
        % -- Get mask visibilities
        Vis	= get_param(block, 'maskVisibilities');
        
        % -- Get mask idx for chancoeff parameter
        setfieldindexnumbers(block);
                 
        % -- Update mask properties for Channel Coefficients parameter
        if strcmp(get_param(block,'specchan'),'Dialog')
            if strcmp(Vis{idxChancoeff},'off')
                Vis{idxChancoeff}='on';
                set_param(block,'maskVisibilities', Vis);
            end
        else    
            if strcmp(Vis{idxChancoeff},'on')
                Vis{idxChancoeff}='off';
                set_param(block,'maskVisibilities', Vis);
            end
        end        
        
    case {'cbEnpreamble','cbEnpostamble'} % Callback for 
        % enpreamble and enpostamble parameters
        
        % -- Get mask enables
        En = get_param(block, 'maskEnables');
        
        % -- Get mask idx for preamble parameter
        setfieldindexnumbers(block);
        
        if strcmp(action,'cbEnpreamble')
            % -- Toggle mask properties for 'Expected Preamble' parameter
            En{idxPreamble} = get_param(block,'enpreamble');
        else
            % -- Toggle mask properties for 'Expected Postamble' parameter
            En{idxPostamble}=get_param(block,'enpostamble');
        end
        
        %-- Update mask enables
        set_param(block,'maskEnables', En);
        
    case 'cbOpmode' % Callback for 'Operation Mode' parameter
        
        % -- Get mask idx for opmode parameter
        setfieldindexnumbers(block);
        
        % -- Get mask visibilities
        Vis	= get_param(block, 'maskVisibilities');
        idxVis = [idxEnpreamble idxPreamble idxEnpostamble idxPostamble];
        
        if strcmp(get_param(block, 'opmode'),'Continuous with reset option'); 
            if strcmp(Vis{idxReset},'off')
                Vis{idxReset} = 'on';   
                [Vis{idxVis}] = deal('off');
                
                % -- Set mask visibilities 
                set_param(block,'maskVisibilities', Vis);
            end
        else % Periodic reset mode
            if strcmp(Vis{idxReset},'on')
                Vis{idxReset} = 'off';   
                [Vis{idxVis}] = deal('on');
                                
                % -- Set mask visibilities and enables
                set_param(block,'maskVisibilities', Vis);
            end
        end
        
    case 'init'
               
        % -- Get mask values and enables
        En  = get_param(block, 'maskEnables');
        Vals  = get_param(block, 'maskValues');
        
        % -- Get mask idx for Reset and Specchan parameter
        setfieldindexnumbers(block);

        %--  Draw icon
        isRst  = strcmp(Vals{idxReset},'on') && strcmp(En{idxReset},'on') && ...
            strcmp(get_param(block, 'opmode'),'Continuous with reset option');
        isChan = strcmp(Vals{idxSpecchan},'Input port');
        iconStr = drawIconFcn(isRst, isChan);
        
        % -- Convert constellation points to complex
        try
            constel = evalin('caller',(Vals{idxConstpts}));
            cplxconstpts = complex(real(constel),imag(constel));
        catch
            cplxconstpts = [];
            errStr.msg = ['Signal constellation must be a vector ' ...
                         'of at least two elements, representing the set ' ...
                         'of constellation points that the modulator in ' ...
                         'the current model can generate.'];
            errStr.mmi = 'commblks:commblkmlseeq:constPtsCheck';
            
            return;
        end

        %-- Check parameters
        errStr = checkParamsMlseeq(block,cplxconstpts);

end % switch-end case

%********************************************************************
function s = drawIconFcn(isRst, isChan)

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
if isRst && isChan    
    p.i2=2; p.i2s='Ch'; p.i3=3; p.i3s='Rst';
elseif isChan
    p.i2=2; p.i2s='Ch'; p.i3=2; p.i3s='Ch';
elseif isRst
    p.i2=2; p.i2s='Rst';  p.i3=2; p.i3s='Rst';
else
    p.i2=1; p.i2s='';  p.i3=1; p.i3s='';
end

% -- Setup outport label
p.o1 = 1; p.o1s = '';

% -- Store structure
s.ports = p;

%*********************************************************************
function s = checkParamsMlseeq(block,cplxconstpts)

setallfieldvalues(block);

%-- Init structure
s.msg = [];

%-- Check channel coefficients (only if Dialog selected)
% Error out if empty, non-numeric, matrix, column vector
% or non-multiple of number of samples per symbol
if (maskSpecchan==2)
    if (~isscalar(maskNumsamp)) || (isempty(maskChancoeff) || ismatrix(maskChancoeff) || ...
            ~isnumeric(maskChancoeff) || size(maskChancoeff,2)~=1 || ...
            mod(length(maskChancoeff),maskNumsamp))
        s.msg = ['Channel coefficients must be a column vector whose '...
                'length is a multiple of the Samples per symbol ' ...
                'parameter.'];
        s.mmi = 'commblks:commblkmlseeq:chCoeffCheck';
    end
end

%-- Check constellation points: 
% Error out if empty, matrix, 1D vector, non-numeric or non-complex
if isempty(cplxconstpts) || ismatrix(cplxconstpts) || length(cplxconstpts)<2 ...
    || ~isnumeric(cplxconstpts) || any(isreal(cplxconstpts)) ...
    || (length(unique(cplxconstpts)) ~= length(cplxconstpts))
    s.msg = ['Signal constellation must be a vector of at least ' ...
            'two elements, representing the set of constellation points ' ...
            'that the modulator in the current model can generate.'];
    s.mmi = 'commblks:commblkmlseeq:constPtsCheck';
end

%-- Check Traceback depth: 
% Error out if empty, vector, negative or less than 1
if isempty(maskTbdepth) || ~isscalar(maskTbdepth) ||  ...
        ~isinteger(maskTbdepth) || maskTbdepth<1
    s.msg = 'Traceback depth must be a positive integer.';
    s.mmi = 'commblks:commblkmlseeq:tbDepthCheck';
end

%-- Expected preamble (only if selected)
% Error out if empty, matrix, non-numeric, complex and out of range (0..M-1)
if (maskOpmode ==2) && (maskEnpreamble==1)
    if isempty(maskPreamble) || ismatrix(maskPreamble) || ...
            ~isnumeric(maskPreamble) || ~isreal(maskPreamble) || ...
            min(maskPreamble)<0 || max(maskPreamble)>=length(maskConstpts)
        s.msg = ['Expected preamble must be a vector of integers between 0 ' ...
                'and the order of the constellation minus 1.'];
        s.mmi = 'commblks:commblkmlseeq:preambleCheck';
    end
end
   
%-- Expected postmble (only if selected)
% Error out if empty, matrix, non-numeric, complex and out of range (0..M-1)
if (maskOpmode ==2) && (maskEnpostamble==1)
    if isempty(maskPostamble) || ismatrix(maskPostamble) || ...
            ~isnumeric(maskPostamble) || ~isreal(maskPostamble) || ...
            min(maskPostamble)<0 || max(maskPostamble)>=length(maskConstpts)
        s.msg = ['Expected postamble must be a vector of integers between 0 '...
                'and the order of the constellation minus 1.'];
        s.mmi = 'commblks:commblkmlseeq:postambleCheck';
    end
end

%-- Number of samples per symbol
% Error out if empty, vector, negative or less than 1
if isempty(maskNumsamp) || ~isscalar(maskNumsamp) ||...
        ~isinteger(maskNumsamp) || maskNumsamp<1
    s.msg = 'Samples per symbol must be a positive integer.';
    s.mmi = 'commblks:commblkmlseeq:numSampCheck';
end

%-- Memory limitation (only if channel coefficients via dialog is selected)
% Warn if the number of states > 2^16 and error out if number of states >
% 2^20

if (maskSpecchan==2)
    
    if ((length(cplxconstpts)^length(maskChancoeff)-1) > 2^20)
        s.msg = ['MLSE Equalizer parameter settings describe a ' ...
                'trellis with more than 2^20 states leading ' ...
                'to memory allocation failure']; 
        s.mmi = 'commblks:commblkmlseeq:memCheck';
     elseif ((length(cplxconstpts)^length(maskChancoeff)-1) > 2^16)
          warndlg(['MLSE Equalizer parameter settings create a trellis ' ...
                  'with more than 2^16 states.'],'Out of Memory Warning');
    end
end

%[EOF]