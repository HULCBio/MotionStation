function compute_state_enums(file,chart)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.3.4.1 $  $Date: 2004/04/13 03:12:39 $
   global gChartInfo

	if ~isempty(gChartInfo.states)
		for state = [chart,gChartInfo.states]
			subStates = sf('SubstatesOf',state);
			if(~isempty(subStates))
				switch sf('get',state,'.decomposition')
				case 0  % CLUSTER_STATE
					for substate = subStates
						enumStr = ['IN_',sf('CodegenNameOf',substate),gChartInfo.chartUniquePrefix];
						sf('set',substate,'.activeChildEnumString',enumStr);
					end
				case 1  % SET_STATE
				otherwise,
					construct_coder_error(state,'Bad decomposition.');
				end
			end
		end
	end

