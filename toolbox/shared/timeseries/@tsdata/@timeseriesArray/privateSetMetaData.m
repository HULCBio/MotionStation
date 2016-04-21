function propout = privateSetMetaData(eventSrc,eventData) 

% Copyright 2003 The MathWorks, Inc.

% This setfunction instantiates a listener to Name property of the metadata
% object which is stored inside the metadata property. It keeps the @timeseriesArray
% variable property in sync with the @metadata name property when the
% contents of the metadata proeprty changes and also rebuilds the listener
% when the @timeseries is loaded from disc

% Listener callback to rebuild the @timeseriesArray listener which syncs
% the variable property with the metadata Name property
if isa(eventData,'tsdata.metadata')
  % Removed re: geck 193069 - awaiting a snap in Alsrtw
  rmlisteners(eventSrc)
  eventSrc.addlisteners(handle.listener(eventData,eventData.findprop('Name'),...
                                        'PropertyPostSet',{@localUpdateVarNameChange, eventSrc, eventData}));
  % Need destuction listener for orderly cleanup when time series is created from C
  eventSrc.addlisteners(handle.listener(eventData,'ObjectBeingDestroyed',{@localKillListeners eventSrc}));
end
propout = eventData;

function localUpdateVarNameChange(es,ed, ValueArray, thismetadata)

% Listener callback to the keep the metadata Name in sync with the 
% @timeseriesArray variable property.

% Grab the singleton variable manager
vm = hds.VariableManager;

% Update the Value array variable to reflect the new name
ValueArray.Variable = vm.findvar(thismetadata.Name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inform any parent @dataset objects of the change. (To be
% implemented in HDS >R14)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

function localKillListeners(es,ed,h)
  
h.rmlisteners
