function h = loopdata
%LOOPDATA  Constructor for loop data repository.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $ $Date: 2002/04/10 04:52:58 $

% Create class instance
h = sisodata.loopdata;

% Initialization
h.SystemName = 'untitled';
h.Compensator = sisodata.tunedmodel('C');
h.Filter = sisodata.tunedmodel('F');
h.Plant = sisodata.fixedmodel;
h.Sensor = sisodata.fixedmodel;

% Initialize design history
h.SavedDesigns = struct(...
   'Name',cell(0,1),...
   'Configuration',[],...
   'FeedbackSign',[],...
   'Plant',[],...
   'Sensor',[],...
   'Filter',[],...
   'Compensator',[]);

% Listeners to compensator (@tunedmodel) properties
L = handle.listener(h.Compensator,findprop(h.Compensator,'Format'),...
   'PropertyPostSet',@LocalChangeFormat);
L.CallbackTarget = h;

% Store references to listeners
h.Listeners = L;


%-------------------------Listeners-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalChangeFormat %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalChangeFormat(LoopData,event)
% Update all plots when changing format (the "normalized" data used in the root locus
% and bode editors becomes stale, causing bad behaviors when changing format, then
% modifying the loop gain, see geck 88273)
LoopData.dataevent('all');
