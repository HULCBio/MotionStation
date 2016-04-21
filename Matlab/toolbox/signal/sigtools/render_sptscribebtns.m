function hscribebtns = render_sptscribebtns(htoolbar)
%RENDER_SPTSCRIBEBTNS Render the annotation portion of a toolbar.
%   HSCRIBEBTNS = RENDER_SPTSCRIBEBTNS(HTOOLBAR) creates the annotation
%   portion of a toolbar  (Edit Plot, Insert Arrow, etc) on a toolbar
%   parented by HTOOLBAR and return the handles  to the buttons.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/04/13 00:32:42 $

if usejava('jvm')

    hscribebtns(1) = uitoolfactory(htoolbar, 'Standard.EditPlot');
    hscribebtns(2) = uitoolfactory(htoolbar, 'Annotation.InsertRectangle');
    hscribebtns(3) = uitoolfactory(htoolbar, 'Annotation.InsertTextbox');
    hscribebtns(4) = uitoolfactory(htoolbar, 'Annotation.InsertDoubleArrow');
    hscribebtns(5) = uitoolfactory(htoolbar, 'Annotation.InsertArrow');
    hscribebtns(6) = uitoolfactory(htoolbar, 'Annotation.InsertLine');
    hscribebtns(7) = uitoolfactory(htoolbar, 'Annotation.Pin');

    % Turn on the separator between the File buttons, the edit and the first
    % annotation button.
    set(hscribebtns(1:2), 'Separator', 'On');
end

% [EOF]
