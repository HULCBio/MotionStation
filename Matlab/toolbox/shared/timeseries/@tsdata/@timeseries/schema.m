function schema
%SCHEMA Defines properties for @timeseries class.

%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:33:53 $


pparent = findpackage('hds');
c = schema.class(findpackage('tsdata'),'timeseries',findclass(pparent,'dataset'));

% Public properties
schema.prop(c,'Events','MATLAB array');
schema.prop(c,'Name','string');

% Need separate callbacks for each prop because setFunction &
% getFunction will not support cell array callbacks
p = schema.prop(c,'Time','MATLAB array');
p.SetFunction = @LocalSetTime;
p.GetFunction = @LocalGetTime;
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'TimeInfo','handle');  
p.SetFunction = @LocalSetTimeMetaData;
p.GetFunction = @LocalGetTimeMetaData;  
p.AccessFlags.Serialize = 'off';
% Init flag set to off to prevent metadata being cleared when an 
% empty timeseries object is created. Empty time series must have 
% intact metadata so that empty Time and Data vectors cen be retrieved 
% without error
p.AccessFlags.Init = 'off';
p = schema.prop(c,'Data','MATLAB array');
p.SetFunction = @LocalSetData;
p.GetFunction = @LocalGetData;
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'DataInfo','handle');
p.SetFunction = @LocalSetDataMetaData;
p.GetFunction = @LocalGetDataMetaData;  
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'off';
p = schema.prop(c,'Quality','MATLAB array'); 
p.SetFunction = @LocalSetQuality;
p.GetFunction = @LocalGetQuality;    
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'QualityInfo','handle');   
p.SetFunction = @LocalSetQualityMetaData;
p.GetFunction = @LocalGetQualityMetaData;
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'off';

% define events
schema.event(c,'datachange'); 

% Note the actual data storage manipulation is performed in the two utility
% methods utManageDataStorage and utManageMetaDataStorage since provate
% property access is required which is not available in local fcns

function propout = LocalSetTime(eventsrc, eventdata)

% Time property setfcn
propout = utManageDataStorage(eventsrc, eventdata, 'Time', true);

function propout = LocalGetTime(eventsrc, eventdata)

% Time property getfcn
propout = utManageDataStorage(eventsrc, eventdata, 'Time', false);

function propout = LocalSetTimeMetaData(eventsrc,eventdata)

% Time metadata set fcn
propout = utManageMetaDataStorage(eventsrc,eventdata, 'Time', true);

function propout = LocalSetDataMetaData(eventsrc,eventdata)

% Datainfo set fcn
propout = utManageMetaDataStorage(eventsrc,eventdata,'Data',true);

function propout = LocalSetData(eventsrc, eventdata)

% Data property setfcn
propout = utManageDataStorage(eventsrc, eventdata, 'Data', true);

function propout = LocalGetData(eventsrc, eventdata)

% Data proeprty get fcn
propout = utManageDataStorage(eventsrc, eventdata, 'Data', false);

function propout = LocalGetDataMetaData(eventsrc,eventdata)

% DataInfo property getfcn
propout =  utManageMetaDataStorage(eventsrc,eventdata,'Data',false);

function propout = LocalGetTimeMetaData(eventsrc,eventdata)

% Time metadata getfcn
% Read metadata
propout = utManageMetaDataStorage(eventsrc,eventdata,'Time',false);

function propout = LocalSetQuality(eventsrc, eventdata)

% Quality proprety set fcn
propout = utManageDataStorage(eventsrc, eventdata, 'Quality', true);

function propout = LocalGetQuality(eventsrc, eventdata)

% Quality property get fcn
propout = utManageDataStorage(eventsrc, eventdata, 'Quality', false);

function propout = LocalSetQualityMetaData(eventsrc,eventdata)

% QualityInfo set fcn
propout = utManageMetaDataStorage(eventsrc,eventdata,'Quality',true);

function propout = LocalGetQualityMetaData(eventsrc,eventdata)
 
% Qualityinfo get fcn
propout = utManageMetaDataStorage(eventsrc,eventdata,'Quality',false);
