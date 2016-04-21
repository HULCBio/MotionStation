function cvstruct = report_decision_info(cvstruct,decisions)
% DECISION_INFO - Synthesize decision coverage data
% for a all the decision objects.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:45 $

    global gdecision gFrmt;
    decCnt = length(decisions);
    
    % Preallocate the structure entries
    cvstruct.decisions = struct( ...
                            'cvId',             num2cell(decisions), ...
                            'text',             cell(1,decCnt), ...
                            'numOutcomes',      cell(1,decCnt), ...
                            'totals',           cell(1,decCnt), ...
                            'outCnts',          cell(1,decCnt), ...
                            'covered',          cell(1,decCnt), ...
                            'outcome',          cell(1,decCnt));
    
    for i=1:decCnt
        decId = decisions(i);
        cvstruct.decisions(i).text = report_fix_html(cv('TextOf',decId,-1,[],gFrmt.txtDetail)); 
        [outcomes,startIdx]  = cv('get',decId,'.dc.numOutcomes','.dc.baseIdx');
        cvstruct.decisions(i).numOutcomes = outcomes;
        if outcomes==1
            cvstruct.decisions(i).totals = gdecision(startIdx+1,:);
        else
            cvstruct.decisions(i).totals = sum(gdecision((startIdx+1):(startIdx+outcomes),:));
        end
        if outcomes==1
            cvstruct.decisions(i).outCnts = gdecision((startIdx+1):(startIdx+outcomes),:)>0;
        else
            cvstruct.decisions(i).outCnts = sum(gdecision((startIdx+1):(startIdx+outcomes),:)>0);
        end

        cvstruct.decisions(i).covered = (cvstruct.decisions(i).outCnts(end)==outcomes);
        for j = 1:outcomes;
            cvstruct.decisions(i).outcome(j).execCount = gdecision(startIdx+j,:);
            cvstruct.decisions(i).outcome(j).text = report_fix_html(cv('TextOf',decId,j-1,[],gFrmt.txtDetail));
        end
    end




    
