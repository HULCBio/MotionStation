function hout = LinearizationInspector
%% LINEARIZASTIONINSPECTOR Constructor to create a singleton handle to the
%% linearization inspector storage class

%  Author(s): John Glass
%  Copyright 1986-2002 The MathWorks, Inc.

mlock
persistent this

if isempty(this)
    this = GenericLinearizationNodes.LinearizationInspector;
    
    %% Add the listener to the class to clear the properties if it is being
    %% deleted.
%     this.listeners = handle.listener(this,'ObjectBeingDestroyed',{@LocalDeleteObject, this});
end

hout = this;

%% ------------------------------------------------------------------------
%% LOCALDELETEOBJECT
%% ------------------------------------------------------------------------
function LocalDeleteObject(this)

delete(this.SystemListBoxUDD)
delete(this.PlotBlockLinearizationButtonUDD);
delete(this.listeners);
