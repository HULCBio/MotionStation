function appDataStruct = wizard(appDataStruct, callbackStruct, wizardName)
%UIWIZARD Template for building GUI wizards.
%
% INPUTS: appDataStruct: can be empty or have fields chock full of nuts
%         callbackStruct: requires these fields with valid function pointers.
%                         doCancel      - call on cancel press and window close
%                         doBack        - call on back press
%                         doNext        - call on next press
%                         doFinish      - call on finish press
%                         doKeyPress    - call on key press over window
%                         doPanelChange - call on card panel change
%
% OUTPUTS: appDataStruct: any fields passed in get passed out.  These fields get set.
%                         initMessage   -
%                         cardPanel     -
%
%                         cancelButton  -
%                         backButton    -
%                         nextButton    -
%                         finishButton  -
%
%                         fontName      -
%                         fontSize      - 
%
%                         frameHandle   -
%                         HGHandle      - e.g. waitfor(appDataStruct.HGHandle)
%
%
% See also: UIIMPORT

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.3 $  $Date: 2002/04/15 03:27:19 $

% NOTE: This function uses undocumented java objects whose behavior will
%       change in future releases.  When using this function as an example,
%       use java objects from the java.awt or javax.swing packages to ensure
%       forward compatibility.

if ~usejava('mwt')
    error('Java is not currently fully enabled MWT not available.  See IMPORTDATA for other options.');
end

if nargin < 3
    error('Usage: appDataStruct = wizard(appDataStruct, callbackStruct, wizardName)');
end

%%% could do boilerplate "check the input struct field" dance here
if ~isstruct(callbackStruct) & ~isempty(callbackStruct)
    error('CallbackStruct must be a struct')
end
if ~isfield(callbackStruct,'doCancel')
    callbackStruct.doCancel = {@closeWindow,[]};
    resetCancel = 1;
else
    resetCancel = 0;
end
if ~isfield(callbackStruct,'doBack')
    callbackStruct.doBack = {@disp, 'Back not implemented'};
end
if ~isfield(callbackStruct,'doNext')
    callbackStruct.doNext = {@disp, 'Next not implemented'};
end
if ~isfield(callbackStruct,'doFinish')
    callbackStruct.doFinish = {@disp, 'Finish not implemented'};
end
if ~isfield(callbackStruct,'doKeyPress')
    callbackStruct.doKeyPress = {@disp, 'KeyPress not implemented'};
end
if ~isfield(callbackStruct,'doPanelChange')
    callbackStruct.doPanelChange = {@disp, 'PanelChange not implemented'};
end

% do imports
import java.awt.*;
import com.mathworks.mwt.*;
import com.mathworks.mwt.dialog.*;
import com.mathworks.mwt.window.*;

% create frame
wizardName = sprintf(wizardName);
appDataStruct.frameHandle = MWFrame(wizardName);
appDataStruct.frameHandle.setLayout(BorderLayout(3,3));

if resetCancel
    callbackStruct.doCancel = {@closeWindow,appDataStruct.frameHandle};
end

%try
    % size and show - now so the user thinks we're really fast!
    ss = get(0,'ScreenSize');
    defXSize = 700;
    defYSize = 433;
    % handle small screens nicely (layout won't look as good though...)
    if ss(3) <  defXSize
        defXSize = ss(3) * .8;
        defYSize = defXSize * .6;
    end
    % use a wait cursor
    appDataStruct.frameHandle.setCursor(java.awt.Cursor.WAIT_CURSOR)

    % put a nice message in
    appDataStruct.initMessage = MWLabel(sprintf('    Initializing %s...', wizardName));
    appDataStruct.initMessage.setFont(Font(fontName, 0, fontSize));
    appDataStruct.frameHandle.add(appDataStruct.initMessage, BorderLayout.CENTER);

    xloc = ss(3) / 2 - defXSize / 2;
    yloc = ss(4) / 2 - defYSize / 2;
    p = Point(xloc,yloc);
    appDataStruct.frameHandle.setSize(defXSize,defYSize);
    appDataStruct.frameHandle.setLocation(p);

    appDataStruct.frameHandle.setFont(Font(fontName,0,12));
    appDataStruct.frameHandle.show;

    set(appDataStruct.frameHandle,'Parent',0);
    set(appDataStruct.frameHandle,'Tag',[strrep(wizardName,' ', '_') 'Frame']);

    set(appDataStruct.frameHandle,'WindowClosingCallback', {@closeWindow, appDataStruct.frameHandle});

    % setup window closing callback
    set(appDataStruct.frameHandle,'WindowClosingCallback', callbackStruct.doCancel);
    set(appDataStruct.frameHandle,'KeyPressedCallback', callbackStruct.doKeyPress)

    appDataStruct.HGHandle = findobj(0,'Tag',[strrep(wizardName,' ', '_') 'Frame']);

    % create card panel
    appDataStruct.cardPanel = MWCardPanel;
    appDataStruct.cardPanel.setOpaque(1);
    appDataStruct.cardPanel.setStyle(MWCardPanel.NONE);
    %                    t, l, b, r
    appDataStruct.cardPanel.setMargins(Insets(3, 3, 3, 3));
    appDataStruct.frameHandle.add(appDataStruct.cardPanel, BorderLayout.CENTER);
    % shove into app data before setting callback
    set(appDataStruct.cardPanel, 'ItemStateChangedCallback', callbackStruct.doPanelChange)

    % add wizard controls
    p = MWPanel(FlowLayout(FlowLayout.CENTER,3,3));

    cancelButton = MWButton(sprintf('Cancel'));
    cancelButton.setFont(Font(fontName, 0, fontSize));
    p.add(cancelButton);
    set(cancelButton,'ActionPerformedCallback', callbackStruct.doCancel);
    cancelButton.setEnabled(1);
    appDataStruct.cancelButton = cancelButton;

    backButton   = MWButton(sprintf('< Back'));
    backButton.setFont(Font(fontName, 0, fontSize));
    p.add(backButton);
    set(backButton,'ActionPerformedCallback', callbackStruct.doBack);
    backButton.setEnabled(0);
    appDataStruct.backButton = backButton;

    nextButton   = MWButton(sprintf('Next >'));
    nextButton.setFont(Font(fontName, 0, fontSize));
    p.add(nextButton);
    set(nextButton,'ActionPerformedCallback', callbackStruct.doNext);
    nextButton.setEnabled(0);
    appDataStruct.nextButton = nextButton;

    finishButton = MWButton(sprintf('Finish'));
    finishButton.setFont(Font(fontName, 0, fontSize));
    p.add(finishButton);
    set(finishButton,'ActionPerformedCallback', callbackStruct.doFinish);
    finishButton.setEnabled(0);
    appDataStruct.finishButton = finishButton;

    appDataStruct.frameHandle.add(p, BorderLayout.SOUTH);

    % give these back for consistency
    appDataStruct.fontName = fontName;
    appDataStruct.fontSize = fontSize;
if 0 % catch
    if isfield(appDataStruct,'frameHandle')
        appDataStruct.frameHandle.dispose;
    end
    error(lasterr)
end

function name = fontName
persistent localname;
if isempty(localname)
	lang = get(0,'language');
	if strncmpi(lang,'ja',2)
		localname = get(0,'defaultuicontrolfontname');
	else
		localname = 'Helvetica';
	end
end

name = localname;

function sz = fontSize
sz = 12;


function closeWindow(obj, evd, h)
disp('Cancel not implemented');
if nargin > 2 & ishandle(h)
    h.dispose;
end
