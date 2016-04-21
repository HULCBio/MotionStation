function btn = adddatadlg (ax, fig)
% ADDDATADLG Show a dialog that asks the user to add a data trace to an axes.

% Copyright 2003-2004 The MathWorks, Inc.

panel = com.mathworks.page.plottool.AddDataPanel.getInstance;
figpeer = get (fig, 'javaframe');
canvas = figpeer.getAxisCanvas;    % a Java method
result = panel.showDialogFromMatlab (java(handle(ax)), canvas);
