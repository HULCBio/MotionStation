function res = nice_shot(id, a2, a3),
% NICE_SHOT  Takes a Stateflow object's most flattering 
% picture highlighting it's most salient features

%   Vladimir Kolesnikov
%   Jay R. Torgerson
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.12.2.2 $ $Date: 2004/04/15 00:58:53 $


if strcmp ( id, 'initialize' )
	initialize( [] );
	return;
end
if nargin == 2 & strcmp( a2, 'initialize' )
	initialize( id );
	return;
end
if strcmp ( a2, 'get_image_primitives' )
	if nargin == 2
		get_image_primitives( id, 'no_option' );
	else
		get_image_primitives( id, a3 );	
	end	
	return;
end
if length( id ) ~= 1
	error( 'first parameter must be an object id' );
end
recursive = 1;
if nargin == 2 & strcmp( a2, 'non-recursive' )
	recursive = 0;
end
% preamble
GET = sf('method','get');
SET = sf('method','set');

ISA_STATE = sf(GET, 'default', 'state.isa');
ISA_CHART = sf(GET, 'default', 'chart.isa');
ISA_JUNCTION = sf(GET, 'default', 'junction.isa');
ISA_TRANS = sf(GET, 'default', 'trans.isa');


%
% Construct the object view
%
switch(sf(GET, id, '.isa')),
 case ISA_STATE, 
 	res = get_state_view( id, recursive );
 case ISA_CHART,
	res = get_state_view( id, recursive );
 case ISA_JUNCTION,
	res = get_state_view( id, recursive );
 case ISA_TRANS,
	res = get_state_view( id, recursive );
 otherwise, error('other objects not handled yet!');
end;


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = get_state_view(id, recursive),
%
%
%

ISA_CHART = sf('get', 'default', 'chart.isa');
global dData;
index = dData.map( id );
if index == 0
		initialize( id );
		index = dData.map( id );
end

data = dData.data{ index };
res.data = data{1};  % data{1} contains graphics
res.numBold = length( data{1} );
res.viewRec = data{3};  % data{3} contains the viewRec
% now append all the drawing info of the objects we depend on
%dependOn = data{2};
res.dependOn = data{2};
for i = [id res.dependOn]
	index = dData.map( i );
	if index == 0 
		initialize( i );
		index = dData.map( i );
	end
	depData = dData.data{ index };

	% depData is a cellarray where
	% 1 - graphics
	% 2 - list of dependants
	% 3 - viewrec
	% 4 - id
	% 5 - pointRec
	% 6 - parent
	if recursive == 1 | sf('get', id, '.isa') == ISA_CHART
		res.data{ length(res.data)+1 } = {'beg_obj', i};
		for j = 1:length( depData{1} )
			res.data{ length(res.data)+1 } = depData{1}{j};
		end
		res.data{ length(res.data)+1 } = {'end_obj', i};
	end
	if depData{6} == id
		res.data{length(res.data)+1}={'pointer', depData{4}, depData{5}};
	end
end

function res = get_image_primitives(ids, option),
%  this function returns the cell array of drawing primitives (sets in dData)
%	for each of the object passed and their dependants
%	it also sets the global structure to reflect image sizes
% 	and other relevant information

% it is assumed that if dData contains information on an object
% then this information is correct, and also info on all
% objects in this one's view exists in dData and correct.
% none of this information is recomputed

global dData;
if strcmp( option, 'show_progress' )
	showProgress = 1;
else
	showProgress = 0;
end
if strcmp( option, 'rptgen' )
	noScale = 1;
else
	noScale = 0;
end

if showProgress
   waitbarHandle = waitbar(0, 'SF Print Book: Taking image snapshots', ...
      	'createCancelBtn',['sf(''Private'', ''rg'', ''cancel''); closereq']);
end
len = length( ids );
count = 0;
global gSFCancelFlag;
for i = ids
	count = count + 1;
   index = dData.map( i );
   if gSFCancelFlag
      clear global dData;
      return;
   end
	if showProgress & rem( count, 20 ) == 0
		waitbar( count/len, waitbarHandle );
	end

	if index == 0 % the object's and its children's images not defined

		% assume that report on chart would be requested earlier than report
		% on any of its children. Also, chart would define all the objects in
		% view, therefore the chart may be closed (if we had to open it now) without
		% worry about its children because they must be defined.
	
		isChart = 0;
		curZoomFactor = 0;
		if sf( 'get', 'default', 'chart.isa' ) == sf( 'get', i, '.isa' )
			isChart = 1;
			% first, see if I am open.
			openedNow = 0;
			if ~sf( 'get', i, '.visible' )
				sf('Open', i );
				openedNow = 1;
			end
			maxZoomFactor = 0.2;  % (corresponds to 500% )
			curZoomFactor = sf( 'get', i, '.zoomFactor' );
			sf( 'set', i, '.zoomFactor', maxZoomFactor );
		end				
		if noScale
			initialize( i, 'noScale' );
		else
			initialize( i );
		end
		index = dData.map( i );
	

		% dData.data{index}{2} contains the vector of objects in view
		if index ~= 0
			for j = dData.data{index}{2}
				index = dData.map( j );
				if index == 0 
					if noScale
						initialize( j, 'noScale' );
					else
						initialize( j );
					end
				end
			end
		end % if index ~= 0

		% if we changed the chart view (opened it up, etc.), return to previous state
		if isChart,
			sf( 'set', i, '.zoomFactor', curZoomFactor );
			if openedNow
				sfclose( i );
			end
		end				
	end  % if index == 0
end
if showProgress
  	set( waitbarHandle, 'closeRequestFcn','closereq' );
	close(waitbarHandle);
end

function initialize( ids, varargin )
%
% the function initializes global structure that contains all
% the information on how to draw any object
global dData;
if isempty( ids )
	dData.data = [];
	dData.map = sparse( 100000000, 1 );   
end

for i = ids
	%
	% create the entry on the global table
	%
	GET = sf('method','get');
	SET = sf('method','set');
	ISA_STATE = sf(GET, 'default', 'state.isa');
	ISA_CHART = sf(GET, 'default', 'chart.isa');
	ISA_JUNCTION = sf(GET, 'default', 'junction.isa');
	ISA_TRANS = sf(GET, 'default', 'trans.isa');
	ISA_MACHINE = sf(GET, 'default', 'machine.isa');
	ISA_TARGET = sf(GET, 'default', 'target.isa');

	entry = [];
	sc = 0.1;
	if nargin > 1 & strcmp( varargin{1}, 'noScale' )
		sc = 1;
	end

	switch sf( GET, i, '.isa' ),
		case ISA_STATE,
			% put the rrect entry, and text
			box = sf( GET, i, '.position' );
			w = box( 3 ); h = box( 4 );
			viewRec = [ max( 0, box(1) - w / 20 ), max( 0, box(2) - h / 20), ...
							w * 1.1, h * 1.1 ];
			% object i is always in view, thus do set xor
			chartId = sf( GET, i, '.chart' );
			dependOn = setxor( ...
				sf( 'ObjectsTouchingRectXY', chartId, rectHW2XY(viewRec) ), i );
			pos = sf( GET, i, '.labelPosition' ) *sc;
			graphics{1} = ...
				{'text', pos, -1,	sf( GET, i, '.labelString' ) };
			box = box *sc;
			switch sf( GET, i, '.type' ),
				case 0,  % exclusive OR state. solid line, rounded corner
					graphics{2} = { 'rrect', box, 0 };
				case 1, 	% AND state. Dashed line, rounded corner	
					graphics{2} = { 'rrect', box, 10 * sc };
					% compute the box to encompass the AND state number
					%w = (pos(1)-box(1));	
					%p(1) = box(1) + w*0.2;
					%p(2) = pos(2);
					%p(3) = w * 0.7;
					%p(4) = pos(4);
					fs = sf( 'get', i, '.fontSize' );
					p = [ box(1)+box(3)-fs*2*sc, pos(2) , fs*1.5*sc, fs*1.5*sc ];
					t = [  sf_scalar2str( sf(GET, i, '.priorityNumber') ) ];
					graphics{3} = { 'text', p, -1, t };
					graphics{4} = { 'text', [p(1)+fs/20*sc, p(2:4)], -1, t };
				case 2, 	% Function state. Solid line, squared corner	
					graphics{2} = { 'srect', box, 0 };
					% cut and paste the code from case 1 with slight modifications:
				
					% compute the box to encompass the AND state number
					w = (pos(1)-box(1));
					p(1) = box(1) + w*0.1;
					p(2) = pos(2);
					p(3) = w * 0.8;
					p(4) = pos(4);
					graphics{3} = { 'text', p, -1, 'function'};



				case 3, 	% Group state. Solid line, squared corner	
					graphics{2} = { 'srect', box, 0 };
			end

			pointRec = box; % x y w h	
			parent = sf( GET, i, '.treeNode.parent' );
			entry = { graphics, dependOn, viewRec *sc, i, pointRec, parent };

		case ISA_CHART,
			graphics = {};
			cRect = sf( GET, i, '.objectLimits' );
			% take care of extreme case: empty chart with viewRect = [0 0 0 0]
			if ~any( cRect )
				viewRec = [0 0 0.1 0.1];
			else
				viewRec = [ 0.9 * cRect(1), 0.9 * cRect(3), ...
					(cRect(2)-cRect(1)) * 1.01, (cRect(4)-cRect(3)) * 1.01 ];
			end
			dependOn = sf( 'ObjectsTouchingRectXY', i, rectHW2XY(viewRec) );
			entry = { graphics, dependOn, viewRec*sc, i, [0 0 0 0], i };
		case ISA_JUNCTION,
			
			c = sf ( GET, i, '.position.center' ) *sc;
			rad = sf ( GET, i, '.position.radius' ) *sc; 
			graphics{1} = {'circ', c, rad };
			t = sf( 'get', i, '.labelString' );
			if ~isempty( t )
				fs = min( 2*rad/length(t)/0.65, rad*1.5);
				graphics{2} = {'text', [c(1) - fs*length(t)*0.65/2, c(2)-fs/2], fs, t };
			end
			viewRec = [ c(1) - 2*rad, c(2) - 2*rad, 4*rad, 4*rad ];
			myChart = sf( GET, i, '.chart' );
			dependOn = setxor( ...
				sf( 'ObjectsTouchingRectXY', myChart, rectHW2XY(viewRec /sc) ), i );

			pointRec = [ c(1) - rad, c(2) - rad, 2*rad, 2*rad ];
			parent = sf( GET, i, '.linkNode.parent' );
			entry = { graphics, dependOn, viewRec, i, pointRec, parent };

		case ISA_TRANS,

			%sData = sf( GET, i, '.splineData' )*sc;  % this is retired per Mehran's request
																	% (occupies too much memory)
			sData = sf( 'SplineData', i )'*sc;
			dstPt= sf( GET, i, '.dst.intersection.point' ) *sc;
			sData = [sData, dstPt];
			% determine if the transition should be dashed (no destination)
			dashed = 0;
			if sf( GET, i, '.dst.id' ) == 0
				dashed = 10*sc;
			end
			myChart = sf( GET, i, '.chart' );
			graphics{1} = {'spline', sData, dashed};
			if sf(GET, i, '.hasLabel') ~= 0
				graphics{2} = {'text', ...
					sf(GET, i, '.labelPosition') *sc, -1, sf(GET, i, '.labelString') };
			end
			if sf( GET, i, '.src.id' ) == 0
				% add the filled circle to the beginning of the spline
				c = sf( GET, i, '.tailPos' )*sc;
				% radius is equal to the tailSize
				r = sf( GET, i, '.tailSize' )*sc;
				graphics{length(graphics)+1} = {'fcirc', c, r };
			end
         %graphics{length(graphics)+1} = { ...
         %      'tag', sf( GET, i, '.midPoint' ), 11, sf( GET, i, '.tag' ) };
         
         vRecXY = sf( GET, i, '.limits' );
			
			dependOn = setxor( ...
            sf( 'ObjectsTouchingRectXY', myChart, vRecXY ), i );
         w = vRecXY(2)-vRecXY(1);
         h = vRecXY(4)-vRecXY(3);
			viewRec=[vRecXY(1) - w / 10, vRecXY(3) - h / 10, w * 1.2, h * 1.2] *sc;

			pointRec = [ sf( GET, i, '.midPoint' ), 0.1, 0.1 ] *sc;	
			parent = sf( GET, i, '.linkNode.parent' );
			entry = { graphics, dependOn, viewRec, i, pointRec, parent };

		case ISA_MACHINE,
			entry = { {}, [], [0 0 0 0], i, [0 0 0 0], i };  % no picture for machine
		case ISA_TARGET,
			entry = { {}, [], [0 0 0 0], i, [0 0 0 0], i };  % no picture for target

		otherwise,	
			return;	
	end
	dData.data{length(dData.data)+1} = entry;
	dData.map( i ) = length( dData.data );


end


function res = rectHW2XY( rHW )
res(1) = rHW(1);  % x1
res(3) = rHW(2);	% y1
res(2) = rHW(1) + rHW(3);	% x2
res(4) = rHW(2) + rHW(4);	% x2




function res = smart_clip( id, region )

ISA_STATE = sf(GET, 'default', 'state.isa');
ISA_CHART = sf(GET, 'default', 'chart.isa');
ISA_JUNCTION = sf(GET, 'default', 'junction.isa');
ISA_TRANS = sf(GET, 'default', 'trans.isa');

switch sf( 'get', id, '.isa' )
	case ISA_STATE,
		
	otherwise
		error( 'other objects not handled yet' );
end






