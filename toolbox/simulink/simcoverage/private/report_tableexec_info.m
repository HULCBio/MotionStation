function cvstruct = report_tableexec_info(cvstruct,tables)

% Copyright 2003 The MathWorks, Inc.

    global gtableExec gFrmt gCumulativeReport;
    gFrmt.txtDetail = 2;

    tableCnt = length(tables);
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

    % Preallocate the structure fields
    cvstruct.tables = struct(   'cvId',             num2cell(tables), ...
                                'dimSizes',         cell(1,tableCnt), ... 
                                'breakPtValues',    cell(1,tableCnt), ...
                                'covered',          cell(1,tableCnt), ... 
                                'testData',         cell(1,tableCnt));
    
    for i=1:tableCnt
        tableId = tables(i);
        [cvstruct.tables(i).breakPtValues,cvstruct.tables(i).dimSizes] = ...
                            cv('get',tableId,'.breakPtValues','.dimBrkSizes');

        % WISH we need to modify this to support multiple tables
        for testIdx = 1:coumnCnt
            [notUsed,execCnt,brkEq] = tableinfo(gtableExec.dataObjs{testIdx}, [],0,cv('get',tableId,'.slsfobj'));
            cvstruct.tables(i).testData(testIdx).execCnt = execCnt;
            cvstruct.tables(i).testData(testIdx).breakPtEquality = cat(1,brkEq{:});
        end
            
        % A table is "Covered" if all interpolation intervals are hit.
        cvstruct.tables(i).covered = all(cvstruct.tables(i).testData(end).execCnt);
    end


