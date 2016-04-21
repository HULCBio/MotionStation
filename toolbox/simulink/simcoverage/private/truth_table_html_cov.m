function varargout = truth_table_html_cov(cvStateId, stateId, covdata)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2004/04/15 00:37:50 $

    persistent ccEnum dcEnum;
    
    if isempty(dcEnum)
        dcEnum = cv_metric_names('decision');
        ccEnum = cv_metric_names('condition');
    end

    rootId = covdata.rootID;
    condData = covdata.metrics.condition;
    decData = covdata.metrics.decision;
    
    if isempty(decData)
        str = '';
    end
    
    stringTable = sf('get', stateId, '.truthTable.predicateArray');
    
    % Make the string entries compatible with HTML
    stringTable = strrep(stringTable,'<','&lt;');
    stringTable = strrep(stringTable,'>','&gt;');
    
    [rowCnt, colCnt] = size(stringTable);
    conditionCnt = rowCnt-1;
    textColor = zeros(rowCnt, colCnt);
    cellShading = zeros(rowCnt, colCnt);
    
    %transVect = sf('find','all','transition.linkNode.parent',stateId,'transition.isConditional',1);
    transVect = sf('find','all','transition.linkNode.parent',stateId);
    transCvIds = cv('DecendentsOf',cvStateId);
    cvSfIdList = cv('get',transCvIds,'.handle');
    [sortedTransIdx,sfIntIdx,cvIntIdx] = intersect(transVect,cvSfIdList); % => transVect(sfIntIdx)=cvSfIdList(cvIntIdx)
    
    for idx = 1:length(sortedTransIdx)
        transId = transVect(sfIntIdx(idx));
        transCvId = transCvIds(cvIntIdx(idx));
        if transCvId>0
            decId = cv('MetricGet', transCvId, dcEnum, '.baseObjs');
            transMap = sf('get',transId,'.autogen.mapping');
            
            if ~isempty(transMap) & ~isempty(decId)
                
                decIdx = cv('get',decId(1),  '.dc.baseIdx');    
                colIdx = transMap.index+2;
                
                % Decision coverage information is used to highlight the column
                % and is shown in detail next to the action label
                if ( ((decData(decIdx+1)>0) + (decData(decIdx+2)>0) ) < 2)
                    cellShading(:,colIdx) = 1;
                    cvStr = '<br>(<B><font color=red>';
                    if decData(decIdx+2)==0
                        cvStr = [cvStr 'T'];
                    end
                    if decData(decIdx+1)==0
                        cvStr = [cvStr 'F'];
                    end
                    cvStr = [cvStr '</font></B>)'];
                else
                    cvStr = '<br>(<B><font color=green>ok</font></B>)';
                end   
                entry = stringTable{end,colIdx};
                entry(entry==32) = [];
                stringTable{end,colIdx}  = [entry cvStr];
                
                
                % Condition coverage information is used to highlight the column
                % and is shown in detail next to the predicate value
                if ~isempty(condData)
                    predIdx = 1;
                    conditions = cv('MetricGet', transCvId, ccEnum, '.baseObjs');
                    for rowIdx = 1:conditionCnt
                        if ~isempty(stringTable{rowIdx,colIdx}) & ~strcmp(stringTable{rowIdx,colIdx},'-')
                            
                            if isempty(conditions)
                                if predIdx >1
                                    error('Condition data is poorly organized');
                                else
                                    trueCnt = decData(decIdx+2);
                                    falseCnt = decData(decIdx+1);
                                end
                            else
                                [trueCountIdx,falseCountIdx]  = cv('get',conditions(predIdx), ...
                                                                '.coverage.trueCountIdx', ...
                                                                '.coverage.falseCountIdx');
                                trueCnt = condData(trueCountIdx+1);
                                falseCnt = condData(falseCountIdx+1);
                            end
                            
                            if (trueCnt==0 || falseCnt==0)
                                cvStr = '<br>(<B><font color=red>';
                                if trueCnt==0
                                    cvStr = [cvStr 'T'];
                                end
                                if falseCnt==0
                                    cvStr = [cvStr 'F'];
                                end
                                cvStr = [cvStr '</font></B>)'];
                                textColor(rowIdx,colIdx) = 1;
                            else
                                cvStr = '<br>(<B><font color=green>ok</font></B>)';
                            end
			                entry = stringTable{rowIdx,colIdx};
			                entry(entry==32) = [];
                            stringTable{rowIdx,colIdx}  = [entry cvStr];
                            predIdx = predIdx + 1;
                        end
                    end
                end
            end
        end
    end
    

    tableData.stringTable = stringTable;
    tableData.textColor = textColor;
    tableData.cellShading = cellShading;
    

    tableInfo.table = 'BORDER="1" CELLPADDING="10" CELLSPACING="1"';
    tableInfo.cols = struct('align','LEFT');
    tableInfo.cols(2) = struct('align','CENTER');

    template = {{'ForN',rowCnt, ...
                    {'ForN',colCnt, ...
                        {'#.','@2','@1'}, ...
                    }, ...
                   '\n' ...
               }};
               
    %template = {'#.'};

    str = html_table(stringTable,template,tableInfo);
    varargout{1} = str;
    
    if nargout>1
        varargout{2} = stringTable;
    end

    

