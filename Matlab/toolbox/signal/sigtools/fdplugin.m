function fcnHandles = fdplugin
%FDPLUGIN Define the Filter Design Toolbox plugin to FDATool.

%   Author(s): J. Schickler 
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:31:44 $ 

fcnHandles.fdatool = @insertplugin;
fcnHandles.sidebar = @insertpanel;
fcnHandles.designpanel = @fddesignmethods;
fcnHandles.fvtool  = @installanalyses;
% fcnHandles.importfile = @importfile;


% --------------------------------------------------------------
function fddesignmethods(hd)

% Add IIRLPNORM
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}}, 'iir', 'Least Pth-norm', 'filtdes.iirlpnorm');

% Add IIRLPNORMC
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}}, 'iir', 'Constr. Least Pth-norm', 'filtdes.iirlpnormc');

% Add FIRLPNORM
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}}, 'fir', 'Least Pth-norm', 'filtdes.firlpnorm');

% Add the Arbitrary Group Delay IIRGRPDELAY
addmethod(hd, {'other', 'arbitrarygrp'}, 'iir', 'Constr. Least Pth-norm', ...
    'filtdes.iirgrpdelay', 'Arbitrary Group Delay');

% Add Lowpass Halfband
addmethod(hd, {'lp', 'halfbandlp'}, 'fir', 'Equirippple', 'filtdes.remez', 'Halfband Lowpass');
addmethod(hd, {'lp', 'halfbandlp'}, 'fir', 'Window', 'filtdes.fir1');

% Add Highpass Halfband
addmethod(hd, {'hp', 'halfbandhp'}, 'fir', 'Equirippple', 'filtdes.remez', 'Halfband Highpass');
addmethod(hd, {'hp', 'halfbandhp'}, 'fir', 'Window', 'filtdes.fir1');

% Add Nyquist
addmethod(hd, {'lp', 'nyquist'}, 'fir', 'Equirippple', 'filtdes.remez', 'Nyquist');
addmethod(hd, {'lp', 'nyquist'}, 'fir', 'Window', 'filtdes.fir1');

% Add firceqrip
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}}, 'fir', 'Constrained Equiripple', 'filtdes.firceqrip');
addmethod(hd, {'lp', 'invsinclp'}, 'fir', 'Constrained Equiripple', 'filtdes.firceqrip', ...
    'Inverse Sinc Lowpass');
addmethod(hd, {'hp', 'invsinchp'}, 'fir', 'Constrained Equiripple', 'filtdes.firceqrip', ...
    'Inverse Sinc Highpass');

addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}, {'other', 'diff'}, {'other', 'multiband'}}, ...
    'fir', 'Generalized Equiripple', 'filtdes.gremez');

addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}, {'other', 'diff'}, {'other', 'multiband'}}, ...
    'fir', 'Constr. Band Equiripple', 'filtdes.fircband');

addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}}, 'fir', 'Interpolated FIR', 'filtdes.ifir');

addmethod(hd, {'other', 'peak'}, 'iir', 'Comb', 'filtdes.iircomb', 'Peaking');
addmethod(hd, {'other', 'notch'}, 'iir', 'Comb', 'filtdes.iircomb', 'Notching');

addmethod(hd, {'other', 'notch'}, 'iir', 'Single Notch', 'filtdes.iirnotchpeak');
addmethod(hd, {'other', 'peak'}, 'iir', 'Single Peak', 'filtdes.iirnotchpeak');

hft = getcomponent(hd, '-class', 'siggui.selector', 'Name', 'Response Type');
set(hd, 'ResponseTypeCSHTag', ['fdatool_filter_type_frame' filesep 'filterdesign']);

% --------------------------------------------------------------
function insertplugin(hFDA)
% INSERTPLUGIN makes the necessary changes to FDATool to enable 
%   the launch of the plugin.

% Add a menu item which enables exporting coefficients to XILINX .COE files
hX2COE = addtargetmenu(hFDA,'XILINX Coefficient (.COE) File',{@export2coe,hFDA},'export2COE');

% Add a menu item which enables importing XILINX .COE files
hIfromCOE = addmenu(hFDA,[1 7],'Import Filter From XILINX Coefficient (.COE) File',{@importfromcoe,hFDA},'importfromCOE');

% Insert Filter Design Toolbox help
h = insertfdtbxhelp(hFDA,[3, 10, 12]);

if getappdata(hFDA, 'UseNewQPanel')
    l = handle.listener(hFDA, hFDA.findprop('Filter'), 'PropertyPostSet', ...
        @lclfilter_listener);
    set(l, 'callbackTarget', hFDA);
    sigsetappdata(hFDA, 'qpanel', 'listener', l);
else
    
    % Render the quantization toolbar button
    insert_quantization_button(hFDA);
end

% --------------------------------------------------------------
function insertpanel(hSB)

icons = load('fd_icons');

hFDA = getfdasessionhandle(hSB.FigureHandle);
notblks = ~getflags(hFDA, 'calledby', 'dspblks');

if notblks

    % Only register the QFILTPANEL if this is not called by DSP Blockset and
    % the SFCNPARAMS method does not exist.  This method may not exist if the
    % user has the latest filterdesign but an older dspblks.  This should only
    % happen in between web releases of the 2 products.
    hFDA = getfdasessionhandle(hSB.FigureHandle);
    qopts.tooltip = 'Set quantization parameters';

    qopts.icon    = color2background(icons.quantize);
    % qopts.icon    = icons.quantize; % See G122899

    qopts.csh_tag = ['fdatool_setquantization_tab' filesep 'filterdesign'];
    registerpanel(hSB,@fdatool_qfiltpanel,'quantize',qopts);
end

opts.tooltip = 'Transform filter';
opts.icon    = color2background(icons.xform);
opts.csh_tag = ['fdatool_xform_overview' filesep 'filterdesign'];
% opts.icon    = icons.xform;

registerpanel(hSB,@fdatool_xformtool,'xform',opts);

if notblks && feature('JavaFigures')
    opts.tooltip = 'Create a multirate filter';
    opts.icon    = color2background(icons.multirate);
    opts.csh_tag = ['fdatool_mfilt_overview' filesep 'filterdesign'];

    registerpanel(hSB,@fdatool_mfilttool,'mfilt',opts);
end


% ----------------------------------------------------------------------
function lclfilter_listener(hFDA, eventData)

Hd = getfilter(hFDA);

if isquantized(Hd);
    fdatool_qfiltpanel(hFDA);
end

% --------------------------------------------------------------------
function installanalyses(hFVT)

if isa(hFVT, 'siggui.fvtool'),

    icons = load('fd_icons');

    % Register the analysis with FVTool
    registeranalysis(hFVT, 'Magnitude Response Estimate', 'magestimate', ...
        'filtresp.noisemagnitude', icons.magestimate);
    registeranalysis(hFVT, 'Round-off Noise Power Spectrum', 'noisepower', ...
        'filtresp.noisepowerspectrum', icons.noisepowerspectrum);

else
    adddynprop(hFVT, 'ShowReference', 'on/off', @setsrr, @getsrr)
    adddynprop(hFVT, 'PolyphaseView', 'on/off', @setpolyphase, @getpolyphase)
    
    % Force the get functions to fire so the stored value is correct.  This
    % will keep the set from being "aborted".
    get(hFVT, {'ShowReference', 'PolyphaseView'});
end

% --------------------------------------------------------------------
function sra = setsrr(h, sra)

hfvt = getcomponent(h, 'fvtool');
set(hfvt, 'ShowReference', sra);

% --------------------------------------------------------------------
function sra = getsrr(h, sra)

hfvt = getcomponent(h, 'fvtool');
sra = get(hfvt, 'ShowReference');

% --------------------------------------------------------------------
function poly = setpolyphase(h, poly)

hfvt = getcomponent(h, 'fvtool');
set(hfvt, 'PolyphaseView', poly);

% --------------------------------------------------------------------
function poly = getpolyphase(h, poly)

hfvt = getcomponent(h, 'fvtool');
poly = get(hfvt, 'PolyphaseView');

% --------------------------------------------------------------------
function export2coe(hcbo,eventdata,hFDA)
% Export to XILINX .COE file

filtobj = getfilter(hFDA);
msg     = sprintf(['Your filter must be a quantized, single-section, direct-form FIR filter' ...
            ' to generate a XILINX coefficient (.COE) file.']);
if isquantized(filtobj)
    if strcmpi(filtobj.Arithmetic, 'Fixed') && strcmpi(class(filtobj), 'dfilt.dffir')
        coewrite(filtobj);
    else
        senderror(hFDA, msg);
    end
else
    senderror(hFDA, msg);
end

% --------------------------------------------------------------------
function importfromcoe(hcbo,eventdata,hFDA)
% Import from XILINX .COE file

dlgstr = 'Import Filter From XILINX Coefficient (.COE) File';
filterspec = {'*.coe','XILINX CORE Generator coefficient file(*.coe)';};

% Put up the file selection dialog
[filename, pathname,idx] = lcluigetfile(dlgstr,filterspec);

if ~isempty(filename),
    deffile = [pathname filename];
    
    try  
        filtobj = feval('coeread',deffile);
        
        if ~isempty(filtobj)
            opts.source = 'Imported';
            sendstatus(hFDA,'Importing filter from XILINX coefficient (.COE) file.');
            startrecording(hFDA,'Import XILINX coefficient (.COE) file');
            hFDA.setfilter(filtobj,opts);
            stoprecording(hFDA);
        end
    catch
        % No op
    end
end


% % --------------------------------------------------------------
% function opts = importfile
% % Importing a filter from a text-file.
% 
% % Plug-in to read XILINX CORE Generator coefficient files
% opts.fcn = @coeread;
% opts.filterspec = {'*.coe','XILINX CORE Generator coefficient file(*.coe)';};
% 
% % To add additional file readers
% % opts(2).fcn = @fcnhandle; 
% % opts(2).filterspec = {'*.TXT','File Type';};

%------------------------------------------------------------------------
function [filename, pathname,idx] = lcluigetfile(dlgStr,fileformat)
% Local UIGETFILE: Return an empty string for the "Cancel" case

[filename, pathname,idx] = uigetfile(fileformat,dlgStr);

% filename is 0 if "Cancel" was clicked
if filename == 0, filename = ''; end



% [EOF]
