function varargout = dspblkfirrcos2(action,varargin)
% DSPBLKFIRRCOS2 Mask function for the Signal Processing Blockset
%   FIR Raised Cosine Filter Block.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:06:33 $

blk = gcb;  % Cache the block handle once
if nargin==0
    action = 'dynamic';
end

switch action 
    case 'dynamic',
        % Execute dynamic dialogs
        mask_enables      = get_param(blk,'maskenables');
        mask_visibilities = get_param(blk,'maskvisibilities');
        mask_prompts      = get_param(blk,'maskprompts');

        % Cash all block parameter values here for comparisons at the end.
        % This prevents forcing the model to be edited ("dirtied") if a
        % parameter value/enable/visibility was not really changed.
        orig_enables      = mask_enables;
        orig_visibilities = mask_visibilities;
        orig_prompts      = mask_prompts;

        % Depending on the popup-menu choice, the fourth mask parameter
        % (i.e. Design Method) can enable or disable the fifth or sixth
        % mask parameter (i.e. Transition bandwidth, Rolloff factor).
        if strcmp(get_param(blk,'rolloff_type'),'Rolloff factor'),
            mask_enables{5}      = 'off';
            mask_visibilities{5} = 'off';
            mask_enables{6}      = 'on';
            mask_visibilities{6} = 'on';
        else
            mask_enables{5}      = 'on';
            mask_visibilities{5} = 'on';
            mask_enables{6}      = 'off';
            mask_visibilities{6} = 'off';
        end

        % If the window type is Chebyshev or Kaiser, then
        % additional window shape parameters are necessary.
        % Code to handle these extra parameters follows.
        win_type = get_param(blk,'window_type');

        switch win_type
        case 'Chebyshev',
           mask_enables{9} = 'off';
           mask_enables{8} = 'on';
        case 'Kaiser',
           mask_enables{8} = 'off';
           mask_enables{9} = 'on';
        otherwise,
           mask_enables{8} = 'off';
           mask_enables{9} = 'off';
        end % switch for win_type
        
        % Update the masked block parameters and GUI look
        %   only if necessary (makes GUI dirty):
        if ~isequal(mask_enables, orig_enables),
           set_param(blk, 'maskenables', mask_enables);
        end
        if ~isequal(mask_visibilities, orig_visibilities),
           set_param(blk, 'maskvisibilities', mask_visibilities);
        end
        if ~isequal(mask_prompts, orig_prompts),
           set_param(blk, 'maskprompts', mask_prompts);
        end
        
     case 'design'
        
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CHECK PARAMETERS, DESIGN THE RAISED COSINE FILTER
        % AND REDRAW THE ICON DISPLAYED WITH THE FREQ RESPONSE
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % INPUT ARGUMENTS: filter_order,upper_cutoff_freq,rolloff_type,
        %                  transition_bw,rolloff_factor, window_type,
        %                  Rs,enable_sqrt_design,
        %                  frame_based,num_chans, Kbeta

        % Make sure that the number of input parameters is expected
        if (nargin ~= 10),
            error('Unexpected number of input parameters in init block mask call');
        end

        % Make sure that the value entered for filter order is a positive integer
        % and correct the value if it is not.  This is a user bad-use-case.
        filter_order = varargin{1};

        % Check for inf or Nan filter order
        if isnan(filter_order) | isinf(filter_order),
            error('NaN or Inf not allowed for filter order.');
        end
   
        % Check for non-integer filter order
        if ~isequal(floor(filter_order), filter_order),
            error('Filter order must be an integer value.');
        end

        % Check for (filter order < 1)
        if filter_order < 1,
            error('Filter order must be positive.');
        end

        % Check the passband (upper cutoff freq) bandwidth parameter
        % and set it appropriately if not realizable
        passbandwidth  = varargin{2};

        % First check for inf or Nan - cannot handle this case
        if isnan(passbandwidth) | isinf(passbandwidth),
            error('NaN or Inf not allowed for upper cutoff frequency.');
        elseif ( passbandwidth < eps ),
            error('Upper cutoff frequency entered is less than realizable precision.');
        elseif ( passbandwidth > 1.0 ),
            error('Upper cutoff frequency entered exceeds Nyquist bounds');
        end

        % Depending on the popup-menu choice, the fourth mask parameter
        % (i.e. Design Method) can enable or disable the fifth or sixthmask
        % parameter (i.e. Transition bandwidth, Rolloff factor).
        rolloff_type   = varargin{3};
        transition_bw  = varargin{4};  % for checking the transition bandwidth parameter
        rolloff_factor = varargin{5};  % for checking the rolloff factor parameter

        if rolloff_type == 2,
            % Design Method is 'Rolloff Factor' for popup index value 2
            if (rolloff_factor < 0) | (rolloff_factor > 1)
                error('Rolloff Factor must be between 0 and 1.');
            end
        else
            % Design Method is 'Transition Bandwidth'

            % First check for inf or Nan - cannot handle this case
            if isnan(transition_bw) | isinf(transition_bw),
                error('NaN or Inf not allowed for transition bandwidth.');
            elseif ( transition_bw < eps ),
                error('Transition bandwidth entered is less than realizable precision');
            end

            if ( (transition_bw + passbandwidth) > 1.0 ),
                error('Total filter design bandwidth entered exceeds Nyquist bounds.');
            end
        end

        % Calculate the underlying delay parameter for the masked DF2T block
        delay = floor( (filter_order + 1)/2 );

        % Calculate the window function to apply to the filter design.
        % Note: If the window type is Chebyshev or Kaiser, then additional
        % window shape parameters are necessary.
        win_type = get_param(blk,'window_type');

        %Bartlett|Blackman|Boxcar|Chebyshev|Hamming|Hann|Hanning|Kaiser|Triangular
        switch win_type
            case 'Chebyshev',
                stopband_dbs = varargin{7};
                window = chebwin(filter_order + 1, stopband_dbs);
            case 'Kaiser',
                beta = varargin{9};
                window = kaiser(filter_order + 1, beta);
            case 'Triangular',
                window = triang(filter_order + 1);
            otherwise,
                window = eval([lower(win_type) '(filter_order + 1)']);
        end % switch for win_type

        % Set the default sample frequency for the filter design functions
        fs = 2;

        enable_sqrt_design = varargin{8};

        % Override LHS for FIRRCOS for error trapping below
        lhs='b';
        filtstr = 'firrcos';

        if (rolloff_type == 2),
            if (enable_sqrt_design),
                % Setup string params for feval function call
                sqrt_option = 'sqrt';
                des_option  = 'rolloff';
            else,
                % Setup string params for feval function call
                sqrt_option = 'normal';
                des_option  = 'rolloff';
            end

            % Trap errors!!!
            s = [lhs '=feval(filtstr,filter_order, passbandwidth, rolloff_factor, fs, des_option, sqrt_option, delay, window);'];
        else
            if (enable_sqrt_design),
                % Setup string params for feval function call
                sqrt_option = 'sqrt';
            else,
                % Setup string params for feval function call
                sqrt_option = 'normal';
            end

            % Trap errors!!!
            s = [lhs '=feval(filtstr,filter_order, passbandwidth, transition_bw, fs, sqrt_option, delay, window);'];
        end

        % Error tolerance support for icon display
        try
            eval(s);
        catch
            b = 1; % Replace filter coefficients with a default upon evaluation error
        end

        % Get filter frequency magnitude response for icon display
        [h,w] = firiconmag(b);

        % Setup block icon title label
        str = 'firrcos';

        % Gather up return arguments:
        varargout = {str, h, w, b};

end % end of switch

% --------------------------------------------------------------------
function [h, w] = firiconmag(b)
% Compute frequency response for icon
h = abs(freqz(b,1,64));
h = h ./ max(h)*0.75;  % Scaled for icon
w = (0:63)/63;  % normalize to [0,1]

% [EOF] dspblkfirrcos2.m
