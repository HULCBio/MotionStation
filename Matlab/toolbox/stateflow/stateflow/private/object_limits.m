function objLimits = object_limits(objIds),
%OBJECT_LIMITS	Computes object limits in dataspace for an arbitrary vector of ids.
%
%
% CAUTION: this routine will ignore 'geometryless' objects; however, it will
%			  choke if all the geometric objects aren't in the same chart.
%
%   Jay R. Torgerson
%	 Vladimir Kolesnikov
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $

	states = sf('get', objIds, 'state.id');
	junctions = sf('get', objIds, 'junction.id');
	trans = sf('get', objIds, 'trans.id');
	charts = sf('get', objIds, 'chart.id');

	geoObjs = [states;junctions;trans];
	geoCharts = sf('get', geoObjs, '.chart');
	allCharts = [charts; geoCharts(:)];
	allCharts(allCharts==0) = [];
	if length(unique(allCharts)) > 1, 
		error('All objects passed to object_limits() must have a common chart parent!');	
	end;

	limits = sf('get', geoObjs, '.limits');
	chartLimits = sf('get', charts, '.objectLimits');

	limits = [limits;chartLimits];

	xMin = min(limits(:,1));
	xMax = max(limits(:,2));
	yMin = min(limits(:, 3));
	yMax = max(limits(:, 4));

	objLimits = [xMin xMax yMin yMax];

	