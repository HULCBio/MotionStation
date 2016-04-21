function ca = rmchartrecur(ca, parentid, level)
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $   $Date: 2004/03/21 23:08:32 $

	STATE_ISA      = sf('get', 'default', 'state.isa' );
	TRANSITION_ISA = sf('get', 'default', 'transition.isa' );

	children = [sf('AllSubstatesOf', parentid) sf('TransitionsOf', parentid)];
	for i = 1:length(children)
		% Cache object isa
		obj_isa = sf('get', children(i), '.isa');

		% 1) Full name
		ca{end + 1, 1} = rmsfnamefull(children(i));

		% 2) Level
		ca{end, 2} = num2str(level + 1);

		% 3) Type
		ca{end, 3} = '';
		switch obj_isa
		case STATE_ISA
			ca{end, 3} = 'StateflowState';
		case TRANSITION_ISA
			ca{end, 3} = 'StateflowTransition';
		end;

		% 4) Short name
		ca{end, 4} = '';
		switch obj_isa
		case STATE_ISA
			ca{end, 4} = sf('get', children(i), '.name');
		case TRANSITION_ISA
			ca{end, 4} = rmsfnamefull(children(i));
		end;

		% Escape forward slash
		ca{end, 4} = strrep(ca{end, 4}, '/', '//');

		% Recurse for states
		if obj_isa == STATE_ISA
			ca = rmchartrecur(ca, children(i), level + 1); 
		end;
	end;
