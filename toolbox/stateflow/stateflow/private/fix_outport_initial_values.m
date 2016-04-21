function fix_outport_initial_values(blockHandles)
%FIX_OUTPORT_INITIAL_VALUES(BLOCKH) takes a handle
% to a Stateflow block and repairs the InitialOutput
% property of all of its outports to '[]'. This function
% is called from Stateflow image during load and copy time
% to fix erroneous existing models.

%	 Vijaya Raghavan
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/04/15 00:57:51 $

	for blockH = blockHandles(:)'
		outportHandles = find_system(blockH,'FollowLinks','On','LookUnderMasks','on','BlockType','Outport');
		for i=1:length(outportHandles)
			set_param(outportHandles(i),'InitialOutput','[]');
		end
	end


