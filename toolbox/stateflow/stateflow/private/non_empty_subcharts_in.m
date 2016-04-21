function subcharts = non_empty_subcharts_in(viewObj)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/04/15 00:58:54 $

subcharts = sf('SubchartsIn', viewObj);
subcharts = fliplr(subcharts); % put reverse order on stack
% filter out empty subcharts
newSubcharts = [];
for i=1:length(subcharts)
	if(~is_empty_subchart(subcharts(i)))
		newSubcharts(end+1) = subcharts(i);
	end
end
subcharts = newSubcharts;
%--------------------------------------------------------------------
function isEmpty = is_empty_subchart(subchart)
%
%
%   
    isEmpty = 0;
    if(sf('get',subchart,'.firstTransition')~=0)
	 return;
    end
    if(sf('get',subchart,'.firstJunction')~=0)
	 return;
    end
    if(sf('get',subchart,'.treeNode.child')~=0)
	 return;
    end
    isEmpty = 1;
    return;
