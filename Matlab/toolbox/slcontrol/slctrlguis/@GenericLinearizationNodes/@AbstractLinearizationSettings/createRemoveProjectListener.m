function createRemoveProjectListener(this,project)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/10 21:51:29 $

this.addListeners(handle.listener(project.up,'ObjectChildRemoved',{@LocalFireProjectDeletedEvent,this,project}));
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalFireProjectDeletedEvent
function LocalFireProjectDeletedEvent(es,ed,this,project)

%% If the deleted child is the same as the project for the linearization task clean up
if (ed.Child == project)
    this.cleanuptask;
end