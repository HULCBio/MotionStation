function varargout = dspblkcicfilter(action,varargin)
% DSPBLKCICFILTER Mask helper function for Signal Processing Blockset
% CIC Decimation AND CIC Interpolation blocks.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Date: 2004/04/20 23:16:12 $ $Revision: 1.1.6.10 $

if nargin==0, action = 'dynamic'; end

currBlock = gcbh;

fdtbxexists = false;
if isfdtbxinstalled,
    fdtbxexists = true;
end

switch action
    case 'icon'
        if strcmp(get_param(currBlock, 'filtFrom'), 'Dialog'),
            % Translate mask parameters into text
            if isCurrentBlockCICDecimation(currBlock),
                str = 'CIC\nDecimation';
            else
                str = 'CIC\nInterpolation';
            end
        else
            % Translate CIC filter object parameters into text
            str = 'CIC Filter\nMFILT\nObject';
        end
        varargout = {str};

    case 'init'
        % Get presently-saved user data for this block
        ud = get_param(currBlock,'UserData');

        maskHelperFiltFrom = get_param(currBlock,'filtFrom');

        if strcmp(maskHelperFiltFrom, 'Dialog'),
            % Translate mask parameters into S-fcn parameters

            [ftype_Sfcn,construct] = getfiltinfo(get_param(currBlock,'ftype'));

            [R_Sfcn,resampPhase_Sfcn,M_Sfcn,N_Sfcn,stage2NWL_Sfcn,...
                outWL_Sfcn,maskHelperFiltObj] = deal(varargin{:});

            maskHelperOutputMode = get_param(currBlock,'outputMode');

            if (strcmp(maskHelperOutputMode, 'Same as input'))
                % Use special coded value for output 'Same as input'
                outWL_Sfcn = -1;
            elseif (strcmp(maskHelperOutputMode, 'Same as final filter stage'))
                if isscalar(stage2NWL_Sfcn) && (stage2NWL_Sfcn == -1),
                    % Same as final (AUTO-COMPUTED) filter stage WL.
                    % Use special coded value for output
                    % 'Same as final filter stage'.
                    outWL_Sfcn = -2;
                else
                    % Same as final (user-specified) filter stage WL
                    outWL_Sfcn = stage2NWL_Sfcn(end);
                end
            end

            % States cannot yet be specified via the mask.
            states_Sfcn = 0;

        else
            % Translate CIC filter object parameters into S-fcn parameters
            
            if strcmp(maskHelperFiltFrom,'Multirate object in workspace') & ~fdtbxexists,
                % The block was saved with the filter specified as an MFILT object
                % (from the Filter Design Tbx), but this session does NOT have
                % the Filter Design Tbx installed.  So we cannot use MFILTs here.
                %
                % Instead, assume that the correct settings were stored in the
                % presently-saved block user data and translate the user data
                % fields to the corresponding S-fcn parameters here.
                if isfield(ud,'paramsFromObj'),
                    [ftype_Sfcn, R_Sfcn, M_Sfcn, N_Sfcn, stage2NWL_Sfcn, outWL_Sfcn,...
                        states_Sfcn, resampPhase_Sfcn] = getParamsFromUD(currBlock);
                else
                    errordlg('Parameters cannot be obtained from UserData');
                    return;
                end
            else
                % Get filter object from input argument.  However,
                % do not automatically overwrite what is in ud.filter!
                % First try to assign the argument into a variable and
                % then check it for validity as the right kind of object.
                % If all this is sucessful, THEN assign into ud.filter
                filterObjToCheck = varargin{7};
                
                % Base filter object checking on the library block type
                if isCurrentBlockCICDecimation(currBlock),
                    if ~any([isa(filterObjToCheck,'mfilt.cicdecim') isa(filterObjToCheck,'mfilt.cicdecimzerolat')]),
                        errStr = [];
                        errStr = ['The variable ',get_param(currBlock,'filtobj'),' must be a MFILT CIC Decimator or Zero-Latency CIC Decimator object.'];
                        errordlg(errStr);
                        return;
                    end
                else
                    if ~any([isa(filterObjToCheck,'mfilt.cicinterp') isa(filterObjToCheck,'mfilt.cicinterpzerolat')]),
                        errStr = [];
                        errStr = ['The variable ',get_param(currBlock,'filtobj'),' must be a MFILT CIC Interpolator or Zero-Latency CIC Interpolator object.'];
                        errordlg(errStr);
                        return;
                    end
                end

                % Filter object is assumed to be valid at this point
                % Overwrite block's saved filter object with new one
                ud.filter = filterObjToCheck;
                
                ftype_Sfcn = getfiltinfo(get(ud.filter,'FilterStructure'));

                % Get the sample rate change factor from the MFILT object.
                decimstrs = {'Cascaded Integrator-Comb Decimator',...
                    'Zero-Latency Cascaded Integrator-Comb Decimator'};
                if strmatch(get(ud.filter,'FilterStructure'),decimstrs),
                    R_Sfcn = get(ud.filter,'DecimationFactor');
                else
                    R_Sfcn = get(ud.filter,'InterpolationFactor');
                end

                M_Sfcn = get(ud.filter,'DifferentialDelay');
                N_Sfcn = get(ud.filter,'NumberOfStages');

                % Interpolator objects do not have a BitsPerStage property.
                if strmatch(get(ud.filter,'FilterStructure'),decimstrs),
                    stage2NWL_Sfcn = get(ud.filter,'BitsPerStage');
                else
                    % Hardcoding to max. word length allowed in object.
                    stage2NWL_Sfcn = 32;
                end

                outWL_Sfcn = get(ud.filter,'OutputBitWidth');

                % Extract the filter states from the filter object once
                % geck #170768 has been addressed.  For now, simply passing
                % a 0 to the S-function.
                % states_Sfcn = get(ud.filter,'States');
                states_Sfcn = 0;
                
                % CIC objects presently assume resample phase is zero
                resampPhase_Sfcn = 0;

                % Store the filter object back in UserData for the case
                % when loading an MFILT directly.
                set_param(currBlock,'UserData',ud);

                % Cache the object parameters in the UserData for the
                % when block is launced without Filter Design Tbx
                % present.
                cacheParamsInUD(currBlock, ftype_Sfcn, R_Sfcn, M_Sfcn, N_Sfcn, ...
                    stage2NWL_Sfcn, outWL_Sfcn, states_Sfcn, resampPhase_Sfcn);
            end
        end

        % Update FVTool (if it's launched)
        if fdtbxexists
            % "Launch FVTool" checkbox present
            % if and only if Filt Des Tbx present
            if strcmp(get_param(currBlock, 'launchFVT'), 'on')
                % "Launch FVTool" checkbox is presently checked
                if strcmp(maskHelperFiltFrom, 'Dialog')
                    % Build a new CIC object from dialog params
                    % NOTE: Only do this when absolutely necessary,
                    % since this greatly slows down initialization.
                    ud.filter = buildfiltobj(construct,R_Sfcn,M_Sfcn,N_Sfcn);
                end

                % Cache the updated UserData (CIC object)
                set_param(currBlock,'UserData',ud);

                lnkfvtool2mask(currBlock);
            end
        end

        % Return S-fcn parameters from initialization call
        varargout = {ftype_Sfcn, R_Sfcn, M_Sfcn, N_Sfcn, stage2NWL_Sfcn, outWL_Sfcn, states_Sfcn, resampPhase_Sfcn};

    case 'dynamic'
        handleDynamicDialogs(currBlock);
        if fdtbxexists,
            if ~isempty(varargin),
                if strcmpi(varargin{1},'on'),
                    if strcmp(get_param(currBlock, 'filtFrom'),'Dialog'),
                        ud = get_param(currBlock,'UserData');
                        R = str2num(get_param(currBlock,'R'));
                        M = str2num(get_param(currBlock,'M'));
                        N = str2num(get_param(currBlock,'N'));
                        ud.filter = mfilt.cicdecim(R,M,N);
                        set_param(currBlock,'UserData',ud);
                    end
                    % Link FVTool in both cases, i.e., filter specified via
                    % dialog or object.
                    lnkfvtool2mask(currBlock);
                else
                    % Handle closing of the GUI.
                    lnkfvtool2mask(currBlock);
                end
            end
        end

    otherwise
        errordlg('Invalid mask helper function argument.');
end

%------------------------------------------------------------
%      FUNCTIONS TO GENERATE FILTER ICONS
%------------------------------------------------------------


%------------------------------------------------------------
%      FUNCTIONS TO HANDLE DYNAMIC DIALOGS
%------------------------------------------------------------
function handleDynamicDialogs(currBlock)
% Read and cache present dialog graphical settings
mvals             = get_param(currBlock, 'MaskValues');
mvisibles         = get_param(currBlock, 'MaskVisibilities');
old_mask_visibles = mvisibles;

% Create flag indicating whether or not the Simulink block being modified
% is CIC Decimation (1) or CIC Interpolation (0) due to different numbers
% of parameters in the block masks (CIC Interp has 1 additional param)
decim = isCurrentBlockCICDecimation(currBlock);

% Compute desired dialog graphical settings
mvisibles = filterParamsProps(mvals,mvisibles,decim);

% Finally, hide the presently unused framing parameter
mvisibles{end} = 'off';

% Update visibilities
if (~isequal(mvisibles, old_mask_visibles))
    set_param(currBlock, 'MaskVisibilities', mvisibles);
end


%------------------------------------------------------------
function mvisibles = filterParamsProps(mvals,mvisibles,decim)

% Create flag indicating whether or not the Filter Design Toolbox exists.
fdtbxexists = false;
if isfdtbxinstalled,
    fdtbxexists = true;
end

if fdtbxexists,
    if strcmpi(mvals{1},'Multirate object in workspace'),
        % Turn off everything except the multirate filter variable edit box
        % and the launching of FVTool.
        if decim,
            % CIC Decimation block
            mvisibles = {'on','on','off','off','off','off','off','off','off','off','on','on'};
        else
            % CIC Interpolation block
            mvisibles = {'on','on','off','off','off','off','off','off','off','off','off','on','on'};
        end
    else
        % Turn on everything except the multirate filter variable edit box
        if decim,
            % CIC Decimation block
            mvisibles = {'on','off','on','on','on','on','on','on','on','on','on','on'};
        else
            % CIC Interpolation block
            mvisibles = {'on','off','on','on','on','on','on','on','on','on','on','on','on'};
        end
    end
else
    % Turn on everything except the ability to use multirate filter
    % objects.
    if decim,
        % CIC Decimation block
        mvisibles = {'off','off','on','on','on','on','on','on','on','on','off','on'};
    else
        % CIC Interpolation block
        mvisibles = {'off','off','on','on','on','on','on','on','on','on','on','off','on'};
    end
end

if decim,
    % CIC Decimation
    outWLModePopupIndex = 9;
else
    % CIC Interpolation -> extra filt stage WL popup param to consider

    % Make sure that the stage word length edit box is not visible while the
    % stage word length mode is "Same as..." (i.e. not "User-defined")
    if ~strcmpi(mvals{8},'User-defined'),
        mvisibles{9}  = 'off';
    end

    outWLModePopupIndex = 10;
end
    
% Common code for both CIC Decimation and CIC Interpolation blocks:
% Make sure that the output word length edit box is not visible while the
% Output word length mode is "Same as..." (i.e. not "User-defined")
if ~strcmpi(mvals{outWLModePopupIndex},'User-defined'),
    mvisibles{outWLModePopupIndex + 1}  = 'off';
end


% -------------------------------------------------------------------------
function [ftype_Sfcn,construct] = getfiltinfo(filtstruct)

switch lower(filtstruct)
    case {'cascaded integrator-comb decimator','decimator'}
        ftype_Sfcn = 1;
        construct  = 'mfilt.cicdecim';

    case {'zero-latency cascaded integrator-comb decimator','zero-latency decimator'}
        ftype_Sfcn = 2;
        construct  = 'mfilt.cicdecimzerolat';

    case {'cascaded integrator-comb interpolator','interpolator'}
        ftype_Sfcn = 3;
        construct  = 'mfilt.cicinterp';

    case {'zero-latency cascaded integrator-comb interpolator','zero-latency interpolator'}
        ftype_Sfcn = 4;
        construct  = 'mfilt.cicinterpzerolat';

    otherwise
        errordlg('Internal error: Stucture not supported.');
end


% -------------------------------------------------------------------------
function filterobj = buildfiltobj(construct,R_Sfcn,M_Sfcn,N_Sfcn)

filterobj = feval(construct,R_Sfcn,M_Sfcn,N_Sfcn);

% -------------------------------------------------------------------------
function cacheParamsInUD(currBlk,ftype_Sfcn, R_Sfcn, M_Sfcn, N_Sfcn, ...
    stage2NWL_Sfcn, outWL_Sfcn, states_Sfcn, resampPhase_Sfcn)

ud = get_param(currBlk,'UserData');
if isstruct(ud),
    ud.paramsFromObj.ftype_Sfcn      = ftype_Sfcn;
    ud.paramsFromObj.R_Sfcn          = R_Sfcn;
    ud.paramsFromObj.M_Sfcn          = M_Sfcn;
    ud.paramsFromObj.N_Sfcn          = N_Sfcn;
    ud.paramsFromObj.stage2NWL_Sfcn  = stage2NWL_Sfcn;
    ud.paramsFromObj.outWL_Sfcn      = outWL_Sfcn;
    ud.paramsFromObj.states_Sfcn     = states_Sfcn;
    ud.paramsFromObj.resampPhase_Sfcn = resampPhase_Sfcn;
    set_param(currBlk,'UserData',ud);
else
    errordlg('UserData data structure is corrupted.')
end


% -------------------------------------------------------------------------
function [ftype_Sfcn, R_Sfcn, M_Sfcn, N_Sfcn, stage2NWL_Sfcn, outWL_Sfcn,...
    states_Sfcn, resampPhase_Sfcn] = getParamsFromUD(currBlk)

ud = get_param(currBlk,'UserData');

ftype_Sfcn       = ud.paramsFromObj.ftype_Sfcn;
R_Sfcn           = ud.paramsFromObj.R_Sfcn;
M_Sfcn           = ud.paramsFromObj.M_Sfcn;
N_Sfcn           = ud.paramsFromObj.N_Sfcn;
stage2NWL_Sfcn   = ud.paramsFromObj.stage2NWL_Sfcn;
outWL_Sfcn       = ud.paramsFromObj.outWL_Sfcn;
states_Sfcn      = ud.paramsFromObj.states_Sfcn;
resampPhase_Sfcn = ud.paramsFromObj.resampPhase_Sfcn;

% -------------------------------------------------------------------------
function str = getFtypeStr(ftype_Sfcn)
switch ftype_Sfcn
    case 1, str = 'Decimator';
    case 2, str = 'Zero-latency decimator';
    case 3, str = 'Interpolator';
    case 4, str = 'Zero-latency interpolator';
end

% -------------------------------------------------------------------------
function decim = isCurrentBlockCICDecimation(currBlock)

refBlockString = get_param(currBlock,'ReferenceBlock');

% When the current block is in a user model:
%    'ReferenceBlock' is either 'CIC\nDecimation' or 'CIC\nInterpolation',
%
% When the current block is in the dspmlti4 library itself:
%    'ReferenceBlock' is '',
%    'Name' is either 'CIC\nDecimation' or 'CIC\nInterpolation'.
%
if (strcmpi(refBlockString,'')),
    decim = strfind(get_param(currBlock,'Name'),'Decim');
else
    decim = strfind(refBlockString,'Decim');
end

% [EOF]
