function varargout = dspblkfdatool(varargin)
% DSPBLKFDATOOL Signal Processing Blockset digital filter block helper function.
%   This function interacts only with the DSP Block Digital Filter
%   and SLFDATOOLINTERFACE


% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.23.4.6 $ $Date: 2004/04/12 23:06:26 $

% The functions in this file are all the calls
% that the block will ever make directly.
%
% Don't put any other functions in here.

[varargout{1:nargout}] = feval(varargin{:});

% ---------------------------------------------------------------
function icon = initializationCommands

hBlk = gcb;

icon = getIcon(hBlk);

blk_ud = get_param(hBlk, 'UserData');
try,

    contained = [hBlk '/Digital Filter'];

    % Get the block parameters from the filter object.
    [lib, b, s] = blockparams(blk_ud.current_filt, 'off');

    % Convert the parameter structure to param value pair
    params = fieldnames(s);
    values = struct2cell(s);
    pv     = [params values]';
    pv     = {pv{:}};

    % If the reference block of the contained block is the same as that
    % needed by the new filter, just set its properties.
    if strcmpi(get_param(contained, 'referenceBlock'), [lib '/' b])
        for indx = 1:2:length(pv)
            set_param(contained, pv{indx}, pv{indx+1});
        end

    else
        % TRY/CATCH because we might have a new filter while the model is
        % running.
        try,
            pos = get_param(contained, 'Position');

            % Try to delete the block.  We will be supporting structures which
            % may need different blocks later on.
            delete_block(contained);

            % Load the library
            isloaded = lclload_system(lib);

            % Add the new block.
            add_block([lib '/' b], contained, pv{:}, 'Position', pos);

            % Close the library if we loaded it.
            if isloaded,
                close_system(lib);
            end

        catch

            if strcmpi(b, 'Digital Filter'),

                % We do not want to set the IRType or structure when the model
                % is running.
                pv(1:4) = [];

                % If the try failed, we want to set the parameters directly.  The
                % try failed because the model is being run.  The delete_block
                % cannot operate.  When this happens, we assume that we will be
                % generating a model that will use the same block as before and we
                % just try to set its properties.
                for indx = 1:2:length(pv)
                    set_param(contained, pv{indx}, pv{indx+1});
                end
            end
        end

    end

catch,
    if ishandle(blk_ud.hFig),
        senderror(getfdasessionhandle(blk_ud.hFig));
    else
        rethrow(lasterror);
    end
end

%-----------------------------------------------------------
function isloaded = lclload_system(name)

isloaded = 0;
if isempty(find_system(0,'Name', name)),
    isloaded = 1;
    w=warning;
    warning('off');
    load_system(name);
    warning(w);
end

% ---------------------------------------------------------------
function OpenFcn
% OPENFCN calls SLFDATOOLINTERFACE's OPENFDATOOL
%   This happens when the block is double-clicked

hBlk = gcbh;
fcns = slfdatoolinterface;
feval(fcns.slOpenFDATool,hBlk);


% ---------------------------------------------------------------
function CloseFcn
% CLOSEFCN is called whenever FDATool must be deleted
%   This happens when the model is closed, and when the block is deleted

hBlk = gcbh;
fcns = slfdatoolinterface;
feval(fcns.slCloseFDATool,hBlk);


% ---------------------------------------------------------------
function NameChange
% NAMECHANGE Changes the name of the block that is stored in FDATOOL's
%   session which will be appended to the title of FDATool.

hBlk = gcbh;
fcns = slfdatoolinterface;
feval(fcns.slNameChange,hBlk);


% ---------------------------------------------------------------
function StartFcn
% STARTFCN Checks to make sure that the block is set properly

hBlk = gcbh;
fcns = slfdatoolinterface;
feval(fcns.slStartFcn,hBlk);


% ---------------------------------------------------------------
function BlockCopy
% BLOCKCOPY Block is being copied from the model or a model is
%   being opened

% Clear out stored figure handle
hBlk = gcbh;
blk_ud = get_param(hBlk,'UserData');
blk_ud.hFDA = [];
set_param(hBlk,'UserData',blk_ud);


% ---------------------------------------------------------------
function ModelCloseFcn
% MODELCLOSEFCN Model containing a digital filter block has been closed
% This is a clean-up routine, which searches for hidden FDATools associated
% with the model and closes them.

hBlk = gcbh;
fcns = slfdatoolinterface;

% Delete all FDATools associated with this model
model_name = bdroot(getfullname(hBlk));
feval(fcns.slModelClose,model_name);

% ---------------------------------------------------------------
%   Utility Functions
% ---------------------------------------------------------------

% ---------------------------------------------------------------
function filterInvalid(hBlk,msg)
% Error mechanism for DSPBlk/FDATool integration

if nargin < 1, hBlk = gcbh; msg = 'is not valid';
elseif nargin < 2
    if ischar(hBlk), msg = hBlk; hBlk = gcbh;
    else, msg = 'is not valid'; end
end

name = getfullname(hBlk);
errordlg(['Filter in ' name ' ' msg '.  Please redesign.'], name);


% % ---------------------------------------------------------------
% function dspWarning(hBlk,msg)
% % Warning mechanism for DSPBlk/FDATool integration
%
% fullname = getfullname(hBlk);
% blockname = get_param(hBlk,'name');
% msg = [fullname ' ' msg];
% warndlg(msg,[blockname ' Block']);


% ---------------------------------------------------------------
function h = getIcon(hBlk)
% GETICON returns the coordinates to plot the icon and a string
%   representing the filter structure to place on the icon.

blk_ud = get_param(hBlk,'userdata');

lastwarn('');
lasterr('');
try,
    w = warning('off');

    Hd = blk_ud.current_filt;

    [num, den] = tf(Hd);

    if den(1) == 0,
        error('First denominator coefficient must be non-zero.');
    end

    h = 20*log10(abs(freqz(Hd,256)));
    warning(w);

    [warnstr warnid] = lastwarn;
    [errstr errid] = lasterr;

    % Ignore Log of Zero warnings
    if any(strcmpi(warnid,{'MATLAB:log:logOfZero','MATLAB:divideByZero'})),
        warnstr = '';

        % Fix the magnitude response for the -Inf case
        h(h == -Inf | h == Inf) = NaN;
    end

    % If there are no warnings or errors return the magnitude response
    if isempty(warnstr) & isempty(errstr) & max(h)-min(h) > .01,
        h = h-min(h);
        h = h/max(h)*.75; % Normalize and leave room for FDATool string

        %If difference is below threshold (.01) plot a straight line
    elseif max(h)-min(h) <= .01
        h = [.5 .5];
    else
        % This will cause 3 question marks to be plotted on the Icon
        h = 'Error State';
    end
catch,
    filterInvalid(hBlk);
    h = 'Error State';
end

% [EOF]
