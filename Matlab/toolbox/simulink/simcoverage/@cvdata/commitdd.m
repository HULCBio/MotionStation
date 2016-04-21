%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/23 03:02:49 $

function ddObj = commitdd(mObj)

	%Validate arguement
	if ~isa(mObj, 'cvdata')
		error('Argument must be a cvdata object')
	end;
	if ~isDerived(mObj)
		error('cvdata must be derived');
	end;
	
	%Get root ID
	p.type = '.';
	p.subs = 'rootId';
	rootId = subsref(mObj, p);
	
	%Create new coverage structure
	cvdata.id        = cv('new', 'testdata');
	cvdata.localData = {};
	
	%Mark as not derived in data dictionary
	cv('set', cvdata.id, '.isDerived', 1);
	cv('set', cvdata.id, '.modelcov', cv('get', rootId, '.modelcov'));
	
	%Copy fields/values of object to structure
	structObj = struct(mObj);
	fNames    = fieldnames(structObj.localData.metrics);
	for i = 1:length(fNames)
		cv('set', cvdata.id, ['.data.' fNames{i}], getfield(structObj.localData.metrics, fNames{i}));
	end; %for
	
	%Add to test list for this root
	cv('RootAddTest', rootId, cvdata.id);
	
	%Create object from structure
	cvdata = class(cvdata, 'cvdata');
	
	%Return newly created object
	ddObj = cvdata;

