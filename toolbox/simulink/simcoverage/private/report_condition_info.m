function cvstruct = report_condition_info(cvstruct,conditions)
% CONDITION_INFO - Synthesize decision coverage data
% for a list of condition objects.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:40 $

    global gcondition gdecision gFrmt;
    condCnt = length(conditions);
    
    % Preallocate the structure entries
    cvstruct.conditions = struct( ...
                            'cvId',                 num2cell(conditions), ...
                            'text',                 cell(1,condCnt), ...
                            'trueCnts',             cell(1,condCnt), ...
                            'falseCnts',            cell(1,condCnt), ...
                            'covered',              cell(1,condCnt));
    
    for i = 1:condCnt
        condId = conditions(i);
        cvstruct.conditions(i).text = report_fix_html(cv('TextOf',condId,-1,[],gFrmt.txtDetail)); 
        [trueCountIdx,falseCountIdx]  = cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx');
        cvstruct.conditions(i).trueCnts = gcondition(trueCountIdx+1,:);
        cvstruct.conditions(i).falseCnts = gcondition(falseCountIdx+1,:);
        cvstruct.conditions(i).covered = cvstruct.conditions(i).trueCnts(end)>0 & cvstruct.conditions(i).falseCnts(end)>0;
    end



    
