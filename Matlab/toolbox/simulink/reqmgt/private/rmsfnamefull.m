function result = rmsfnamefull(id)
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/04 03:39:26 $

	result = '';

	STATE_ISA      = sf('get', 'default', 'state.isa' );
	TRANSITION_ISA = sf('get', 'default', 'transition.isa' );
	objISA         = sf('get', id, '.isa');

	switch objISA
	case STATE_ISA
		result = sf('FullNameOf', id, '/');
	case TRANSITION_ISA
		% Get transition label string
		labelStr = sf('get', id, '.labelString');

		% Get source and dest state IDs, if transition connected
		srcID = sf('get', id, '.src.id');
		dstID = sf('get', id, '.dst.id');

		% Get source and dest state names, if transition connected
		srcName = '';
		dstName = '';
		if sf('ishandle', srcID)
			srcName = sf('FullNameOf', srcID, '/');
		end;
		if sf('ishandle', dstID)
			dstName = sf('FullNameOf', dstID, '/');
		end;

		% Strip junction IDs
		srcName = regexprep(srcName, 'junction\(\d*\)', 'junction');
		dstName = regexprep(dstName, 'junction\(\d*\)', 'junction');

		result = sprintf('%s from "%s" to "%s"', labelStr, srcName, dstName);
	end;