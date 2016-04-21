function okButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:06 $

if ~strcmp(get_param(gcs,'blockdiagramtype'), 'library')
    blk = getBlockName(handles.HilBlkFigureTag);
    UDATA = get_param(blk,'UserData');
    UDATA.guiHandle = [];
    set_param(blk,'UserData',UDATA);
    % Mask init commands:
    [numInports, inports, numOutports, outports] = HilBlkMaskHelper('init');
    HilBlkUpdateIconDrawing(numInports, inports, numOutports, outports);
end

close(handles.HilBlkFigureTag);
