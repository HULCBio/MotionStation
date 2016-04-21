function destfigfile = guidetemplate(frame)

% TBD where to really put this and how to find?

%   Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.17.4.3 $  $Date: 2004/04/10 23:33:45 $

import com.mathworks.ide.layout.*;

destfigfile = 0;

parent = [];
origin = 'STARTUP';

if (nargin == 1)
    parent = frame;
    origin = 'NEW';
end

if isempty(parent)
    optdialog = LayoutNewDialog(origin);
else
    optdialog = LayoutNewDialog(parent, origin);
end
set(optdialog, 'layoutnewDialogEventCallback', {@dialogCallback, optdialog});

optdialog.setVisible(1);

dialogResult = optdialog.getResult;

if ~isempty(dialogResult)
    % user didnt hit ESC or CANCEL.
    templid = [];
    label = [];

    label = char(dialogResult.getButtonLabel);

    if isempty(label)
        return;
    else
        % label is 'Browse' or 'OK'
        % tplfile is a full path and filename w/o an extension.
        tplfile = char(dialogResult.getTemplateFileName);

        % For Open and OK.
        [path, file, ext]= fileparts(char(dialogResult.getDestFileName));
        destmfile = fullfile(path,[file '.m']);
        destfigfile  = fullfile(path,[file '.fig']);

        if ~isempty(tplfile)
            % For OK only.
            saveFlag = dialogResult.isSaveOn;

            if ispc
                tplfile = strrep(tplfile, '/', filesep);
            else
                tplfile = strrep(tplfile, '\', filesep);
            end

            % save the template as the user selected file
            % TBD this should be stored in a list somewhere
            srcmfile = [tplfile,'.m'];
            srcfigfile = [tplfile,'.fig'];

            setappdata(0,'templateFile', srcfigfile);

            if (saveFlag)
                % guicopyToSave returns empty on success
                % TBD something other than error would be good
                setappdata(0,'templateFileSave', 1);
                targetmfile = destmfile;
                targetfigfile  = destfigfile;

                % error(guicopyToSave(srcmfile, destmfile));
            else
                setappdata(0,'templateFileSave', 0);
                % guicopyToTemp just loads a template figure
                % into memory and returns a handle to it.
                temp = tempname;
                targetmfile = [temp, '.m'];
                targetfigfile = [temp, '.fig'];

                destfigfile = targetfigfile;
                %destfigfile = guicopyToTemp(srcmfile);
            end
            % copyfile doesnt force write permissions anymore.
            % Need to force write permission explicitly using fileattrib
            copyfile(srcfigfile, targetfigfile, 'writable');
            fileattrib(targetfigfile, '+w');
            copyfile(srcmfile, targetmfile,'writable');
            fileattrib(targetmfile, '+w');
        end
    end
end


function dialogCallback(evtsrc, evtdata, optdialog)

import com.mathworks.ide.layout.*;

filename = [];
a = get(optdialog, 'LayoutNewDialogEventCallbackData');

if(a.ID == LayoutNewDialog.sBrowseForSave)
    [fname, pname] = uiputfile('untitled.fig', 'Save as:');
    if (fname ~= 0)
        filename = fullfile(pname, fname);
    end
    optdialog.setSaveDestination(filename);
elseif (a.ID == LayoutNewDialog.sBrowseForOpen)
    [fname, pname, filter] = uigetfile({'*.fig','Figures (*.fig)'},'Open:');
    if (fname ~= 0)
        filename = fullfile(pname, fname);
        optdialog.dispose;
    end
    optdialog.setSelectionResult(filename);
elseif (a.ID == LayoutNewDialog.sHelpButtonPress)
    % Help is handled from Java now.
    % helpview([docroot, '/mapfiles/creating_guis.map'], 'guide_templates', 'CSHelpWindow');
elseif (a.ID == LayoutNewDialog.sOKButtonPress)
    % OK proc is handled thru Java for now.
end

