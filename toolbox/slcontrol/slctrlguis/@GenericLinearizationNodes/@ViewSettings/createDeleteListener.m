function createDeleteListener(this)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/10 21:51:40 $

%% Create the delete listener
this.DeleteListeners = handle.listener(this,...
                                'ObjectBeingDestroyed',{@LocalViewBeingDeleted, this});
                            
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalViewBeingDeleted
function LocalViewBeingDeleted(es,ed,this)

%% Delete the ltiviewer if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    close(this.LTIViewer.Figure);
end