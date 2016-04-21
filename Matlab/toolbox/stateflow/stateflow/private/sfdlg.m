function sfdlg(id,deleteObjectOnCancel),
%SFDLG( ID ) Stateflow properties dialog gateway

%	Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.12.2.3 $  $Date: 2004/04/15 01:00:04 $

isa = sf('get',id,'.isa');
machineISA = sf('get','default','machine.isa');
chartISA   = sf('get','default','chart.isa');
stateISA   = sf('get','default','state.isa');
transISA   = sf('get','default','trans.isa');
junctISA   = sf('get','default','junct.isa');
noteISA    = sf('get','default','note.isa');
dataISA    = sf('get','default','data.isa');
eventISA	  = sf('get','default','event.isa');
targetISA  = sf('get','default','target.isa');

if nargin<2
  deleteObjectOnCancel = 0;
else
  h = find(sfroot, 'id', id);
  h.Tag = ['_DDG_INTERMEDIATE_' sf_scalar2str(id)];
end

switch(isa),
  case machineISA,	machinedlg('construct',  id);
  case chartISA,	chartdlg('construct',  id);
  case stateISA,	statedlg('construct',  id);
  case transISA,	transdlg('construct',  id);
  case junctISA,	junctdlg('construct',  id);
  case dataISA,	    datadlg('construct',  id, deleteObjectOnCancel);
  case eventISA,	eventdlg('construct', id, deleteObjectOnCancel); 
  case targetISA,   targetdlg('construct', id, deleteObjectOnCancel);
  otherwise,
    warning('Object''s dialog not found!');
end;


