function cleanuptask(this)
% CLEANUPTASK
%  Task to clean up ltiviewers if a task is removed
%

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/10 21:51:28 $

%% Delete the ltiviewer in the linearization task if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    close(this.LTIViewer.Figure);
end

%% Delete the ltiviewers in the views if needed
Children = this.getChildren;
Views = Children(end).getChildren;
for ct = 1:length(Views)
    if isa(Views(ct).LTIViewer,'viewgui.ltiviewer')
        close(Views(ct).LTIViewer.Figure);
    end
end



