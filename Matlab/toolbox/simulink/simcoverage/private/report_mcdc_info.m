function cvstruct = report_mcdc_info(cvstruct,mcdcentries),

% Copyright 2003 The MathWorks, Inc.

    global gmcdc gFrmt gCumulativeReport;
    gFrmt.txtDetail = 2;
    
	mcdcCnt = length(mcdcentries);
	
	cvstruct.mcdcentries = struct( ...
	                        'cvId',         num2cell(mcdcentries), ...
	                        'text',         cell(1,mcdcCnt), ...
	                        'numPreds',     cell(1,mcdcCnt), ...
	                        'predicate',    cell(1,mcdcCnt), ...
	                        'covered',      cell(1,mcdcCnt));
	
    testCnt = length(cvstruct.tests);
    if testCnt==1,
        coumnCnt = 1;
    else
        coumnCnt = testCnt+1;
    end
    
	%Total col is last col
	if gCumulativeReport
		coumnCnt = testCnt;
	end;

    for i=1:mcdcCnt
        mcdcId = mcdcentries(i);
        [subconditions,numPreds,predAcheivIdx,truePathIdx,falsePathIdx ] = cv('get',mcdcId, ...
                        '.conditions', ...
                        '.numPredicates', ...
                        '.dataBaseIdx.predSatisfied', ...
                        '.dataBaseIdx.trueTableEntry', ...
                        '.dataBaseIdx.falseTableEntry');
                        
        cvstruct.mcdcentries(i).cvId = mcdcId; 
        cvstruct.mcdcentries(i).text = report_fix_html(cv('TextOf',mcdcId,-1,[],gFrmt.txtDetail)); 
        cvstruct.mcdcentries(i).numPreds = numPreds;
        
        for k=1:numPreds
            condId = subconditions(k);
            predEntry.text = report_fix_html(cv('TextOf',condId,-1,[],gFrmt.txtDetail)); 
            predEntry.acheived = gmcdc(predAcheivIdx+k,:)==4;
            for j=1:coumnCnt
                switch(gmcdc(predAcheivIdx+k,j))
                case 0, % Unknown
                    predEntry.trueCombo{j} = 'NA';
                    predEntry.falseCombo{j} = 'NA';
                case 1, % Neither True or False acheived
                    predEntry.trueCombo{j} = ['(' make_n_bold(cv('McdcPathText',mcdcId,gmcdc(truePathIdx+k,j)),k) ')'];
                    predEntry.falseCombo{j} = ['(' make_n_bold(cv('McdcPathText',mcdcId,gmcdc(falsePathIdx+k,j)),k) ')'];
                case 2, % Only True acheived
                    predEntry.trueCombo{j} = make_n_bold(cv('McdcPathText',mcdcId,gmcdc(truePathIdx+k,j)),k);
                    predEntry.falseCombo{j} = ['(' make_n_bold(cv('McdcPathText',mcdcId,gmcdc(falsePathIdx+k,j)),k) ')'];
                case 3, % Only False acheived
                    predEntry.trueCombo{j} = ['(' make_n_bold(cv('McdcPathText',mcdcId,gmcdc(truePathIdx+k,j)),k) ')'];
                    predEntry.falseCombo{j} = make_n_bold(cv('McdcPathText',mcdcId,gmcdc(falsePathIdx+k,j)),k);
                case 4, % True and False acheived
                    predEntry.trueCombo{j} = make_n_bold(cv('McdcPathText',mcdcId,gmcdc(truePathIdx+k,j)),k);
                    predEntry.falseCombo{j} = make_n_bold(cv('McdcPathText',mcdcId,gmcdc(falsePathIdx+k,j)),k);
                end
            end
            cvstruct.mcdcentries(i).predicate(k) = predEntry;
        end
        if sum(gmcdc(predAcheivIdx+1:numPreds,end)>0)==numPreds
            cvstruct.mcdcentries(i).covered = 1;
        else
            cvstruct.mcdcentries(i).covered = 0;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE_N_BOLD - enclose the nth character in <B> </B>.

function out = make_n_bold(str,n),
    if (n>length(str))
        out = str;
    else
        if (n==1)
            out = sprintf('<font color="blue"><B>%s</B></font>%s',str(1),str(2:end));
        elseif (n == length(str))
            out = sprintf('%s<font color="blue"><B>%s</B></font>',str(1:(end-1)),str(end));
        else
            out = sprintf('%s<font color="blue"><B>%s</B></font>%s',str(1:(n-1)),str(n),str((n+1):end));
        end
    end
        



