function markRed = install_informer_text(infrmObj,blkEntry,cvstruct)
%CREATE_INFORMER_TEXT - Generate the abreviated coverage information that
%                       is iserted in the informer window.
%
%  Example Text Messages:
%
%  ----------------------------------------------------
%          Full Coverage
%
%      ==> All coverage metrics fully satisfied.
%
%  ----------------------------------------------------
%          <decision> was never <true,false>.
%          Transition trigger expression was never true.
%
%          <decision> was never <outi>, <outj>, or <outk>.
%          Multiport switch trigger was never 3, or 7.
%
%      ==> Decision coverage not satisfied. There is only
%          a small number of decisions.
%
%  ----------------------------------------------------
%          Full decision coverage. Condition <condi>, <condk>
%          were never true. Condition <condn> was never false.
%
%      ==> Full decision coverage so we report on missing
%          condition coverage elements.
%
%  ----------------------------------------------------
%          Full decision and condition coverage.  Condition
%          <condi>, <condj> have not demonstrated MCDC
%
%      ==> Full decision, condition coverage so we report on
%          missing MCDC elements.
%
%  ----------------------------------------------------
%          Decision  88% (22/25)       Condition  60% (6/10)
%          MCDC      20% (2/10)
%
%          Decision (deep)  88% (22/25)       Condition (deep) 60% (6/10)
%          MCDC     (deep)  20% (2/10)
%
%      ==> Objects with too many coverage elements or container
%          objects further up the hierarchy.
%
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $


    % Calculate structures hasData (0 := No, 1 := Yes 2 := descendents only)
    % and fullCov (0/1)
    tooComplex = 0;


    % Calculate what is fully covered
    %  -1  := undefined
    %   0  := missing coverage
    %   1  := fully covered
    %
    %  fullCov.shallow.decision
    %  fullCov.shallow.condition
    %  fullCov.shallow.mcdc
    %  fullCov.deep.decision
    %  fullCov.deep.condition
    %  fullCov.deep.mcdc

    % Assume that no metrics exist
    fullCov.shallow.decision = -1;
    fullCov.shallow.condition = -1;
    fullCov.shallow.mcdc = -1;
    fullCov.deep.decision = -1;
    fullCov.deep.condition = -1;
    fullCov.deep.mcdc = -1;


    % Decision
    if( isfield(blkEntry,'decision') && ~isempty(blkEntry.decision) && isfield(blkEntry.decision,'decisionIdx'))
        if isfield(blkEntry.decision,'outlocalCnts')
            % A non-leaf object
            if ~isempty(blkEntry.decision.outlocalCnts)
                if (blkEntry.decision.outlocalCnts(end)~=blkEntry.decision.totalLocalCnts)
                    fullCov.shallow.decision = 0;

                    % Too complex after 3 decisions
                    if length(blkEntry.decision.decisionIdx)>3
                        tooComplex = 1;
                    end
                else
                    fullCov.shallow.decision = 1;
                end
            end
            
            % Deep coverage
            if (blkEntry.decision.outTotalCnts(end) == blkEntry.decision.totalTotalCnts)
                fullCov.deep.decision = 1;
            else
                fullCov.deep.decision = 0;
            end    
        else
            % A leaf object
            if (blkEntry.decision.outHitCnts(end)~=blkEntry.decision.totalCnts)
                fullCov.shallow.decision = 0;
                %fullCov.deep.decision = 0;
    
                % Too complex after 3 decisions
                if length(blkEntry.decision.decisionIdx)>3
                    tooComplex = 1;
                end
            else
                fullCov.shallow.decision = 1;
                %fullCov.deep.decision = 1;
            end
        end
    end

    % Condition
    if (isfield(blkEntry,'condition') && isfield(blkEntry.condition,'conditionIdx'))
        if (~isempty(blkEntry.condition.conditionIdx))
            if (blkEntry.condition.localHits(end) == blkEntry.condition.localCnt)
                fullCov.shallow.condition = 1;
            else
                fullCov.shallow.condition = 0;

                % Too complex after 10 conditions
                if length(blkEntry.condition.conditionIdx)>10
                    tooComplex = 1;
                end
            end
        end
        
        if isfield(blkEntry.condition,'totalHits')
            % A non-leaf object
            if (blkEntry.condition.totalHits(end) == blkEntry.condition.totalCnt)
                fullCov.deep.condition = 1;
            else
                fullCov.deep.condition = 0;
            end
        else
            % A leaf object
            %fullCov.deep.condition = fullCov.shallow.condition;
        end
    end        


    % MCDC
    if(isfield(blkEntry,'mcdc') && ~isempty(blkEntry.mcdc))
        if (isfield(blkEntry.mcdc,'mcdcIndex') && ~isempty(blkEntry.mcdc.mcdcIndex))
            mcdcData = cvstruct.mcdcentries(blkEntry.mcdc.mcdcIndex);
        end
        
        if ~isempty(blkEntry.mcdc.localHits)
            if (blkEntry.mcdc.localHits(end) == blkEntry.mcdc.localCnt)
                fullCov.shallow.mcdc = 1;
            else
                fullCov.shallow.mcdc = 0;
            end
        end
        if (isfield(blkEntry.mcdc,'totalHits'))
            % A non-leaf object
            if (blkEntry.mcdc.totalHits(end) == blkEntry.mcdc.totalCnt)
                fullCov.deep.mcdc = 1;
            else
                fullCov.deep.mcdc = 0;
            end
        else
            % A leaf object
            %fullCov.deep.mcdc = fullCov.shallow.mcdc; 
        end
    end        
        
    hasDeepCoverage =   (fullCov.deep.decision ~= -1) || ...
                        (fullCov.deep.condition ~= -1) || ...
                        (fullCov.deep.mcdc ~= -1);
                        
    hasShallowCoverage =   (fullCov.shallow.decision ~= -1) || ...
                           (fullCov.shallow.condition ~= -1) || ...
                           (fullCov.shallow.mcdc ~= -1);
    
    fullDeepCoverage =  (fullCov.deep.decision ~= 0) && ...
                        (fullCov.deep.condition ~= 0) && ...
                        (fullCov.deep.mcdc ~= 0);
    
    fullShallowCoverage =(fullCov.shallow.decision ~= 0) && ...
                         (fullCov.shallow.condition ~= 0) && ...
                         (fullCov.shallow.mcdc ~= 0);
    
    covStr = [bold(object_titleStr_and_link(blkEntry.cvId)) ' <BR>' char(10) '<BR>' char(10) char(10)];

    if fullShallowCoverage && fullDeepCoverage
        covStr = [covStr 'Full Coverage'];
        if ~hasDeepCoverage && ~hasShallowCoverage
            markRed = -1;
            return;
        else
            markRed = 0;
        end
    else
        markRed = 1;
        % In the special case where this object is fully covered but it has descendents that are
        % not fully covered we should report coverage as a non-leaf object
        if (hasShallowCoverage && ~fullShallowCoverage && ~tooComplex)
            if (fullCov.shallow.decision~=0)
                if (fullCov.shallow.condition~=0)
                    if (fullCov.shallow.decision == 1)
                        if (fullCov.shallow.condition == 1)
                            covStr = [covStr 'Full decision and condition coverage. '];
                        else
                            covStr = [covStr 'Full decision coverage. '];
                        end
                    else
                        if (fullCov.shallow.condition == 1)
                            covStr = [covStr 'Full condition coverage. '];
                        end
                    end
                    mcdcData = cvstruct.mcdcentries(blkEntry.mcdc.mcdcIndex);
                    covStr = [covStr missingMCDC(blkEntry,cvstruct,mcdcData)];
                else
                    % Report missing condition coverage
                    condData = cvstruct.conditions(blkEntry.condition.conditionIdx);
                    if (fullCov.shallow.decision == 1)
                        covStr = [covStr 'Full decision coverage. '];
                    end
                    covStr = [covStr missingCondition(blkEntry,cvstruct,condData)];
                end
            else
                % Report missing decision coverage
                decData = cvstruct.decisions(blkEntry.decision.decisionIdx);
                covStr = [covStr missingDecision(blkEntry,cvstruct,decData)];
            end
        end
        if (tooComplex || (hasDeepCoverage && ~fullDeepCoverage))
            % Print a summary table of all the coverage metrics
            covStr = [covStr coverage_summary(blkEntry,cvstruct,fullCov)];
        end
    end

    if ~isempty(infrmObj)
        insert_string(infrmObj, blkEntry, covStr);
    end


function str = coverage_summary(blkEntry,cvstruct,fullCov)

    row = 1;
    col = 1;

    if fullCov.shallow.decision ~= -1 || fullCov.deep.decision ~= -1
        if isfield(blkEntry.decision,'outTotalCnts')
            hit = blkEntry.decision.outTotalCnts;
            count = blkEntry.decision.totalTotalCnts;
        else
            hit = blkEntry.decision.outHitCnts;
            count = blkEntry.decision.totalCnts;
        end
        strTable{row,col} = sprintf('Decision %2.0f%% (%d/%d)',100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end

    if fullCov.shallow.condition ~= -1 || fullCov.deep.condition ~= -1
        if isfield(blkEntry.condition,'totalHits')
            hit = blkEntry.condition.totalHits;
            count = blkEntry.condition.totalCnt;
        else
            hit = blkEntry.condition.localHits;
            hit = blkEntry.condition.localCnt;
        end

        strTable{row,col} = sprintf('Condition %2.0f%% (%d/%d)',100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end

    if fullCov.shallow.mcdc ~= -1 || fullCov.deep.mcdc ~= -1
        if isfield(blkEntry.mcdc,'totalHits');
            hit = blkEntry.mcdc.totalHits;
            count = blkEntry.mcdc.totalCnt;
        else
            hit = blkEntry.mcdc.localHits;
            count = blkEntry.mcdc.localCnt;
        end
        strTable{row,col} = sprintf('MCDC  %2.0f%% (%d/%d)',100*hit/count,hit,count);
        [row,col] = next_cell(row,col);
    end

    if col==1,
        rowCnt = row-1;
    else
        rowCnt = row;
        strTable{row,col} = ' ';
    end

    if (row==1 && col==1)
        str = '';
        return;
    end

    tableInfo.table = '  CELLPADDING="2" CELLSPACING="1"';
    tableInfo.cols = struct('align','LEFT');

    template = {{'ForN',rowCnt, ...
                    {'ForN',2, ...
                        {'#.','@2','@1'}, ...
                    }, ...
                   '\n' ...
               }};

    str = html_table(strTable,template,tableInfo);




function [row,col] = next_cell(row,col)
    if col==2
        col=1;
        row=row+1;
    else
        col=2;
    end


function htmlStr = out_i(decId,index)
    htmlStr = str_to_html(cv('TextOf',decId,index-1,[],1));

function htmlStr = decision_str(decId)
    htmlStr = str_to_html(cv('TextOf',decId,-1,[],1));

function htmlStr = condition_str(condId,index)
    htmlStr = str_to_html(cv('TextOf',condId,-1,[],1));


function str = missingDecision(blkEntry,cvstruct,data)
    str = '';
    for i=1:length(data)
        missingOut = [];
        decId = data(i).cvId;
        allMissing = 1;
        for j=1:data(i).numOutcomes
            if (data(i).outcome(j).execCount(end) == 0)
                missingOut = [missingOut j];
            else
                allMissing = 0;
            end
        end

        if ~isempty(missingOut)
            if allMissing
                str = [decision_str(decId) ' never ' bold('evaluated') '.  '];
            else
                str = [decision_str(decId) ' was never '];
                switch(length(missingOut))
                case 1,
                    str = [str bold(out_i(decId,missingOut)) '.  '];
                case 2,
                    str = [str bold(out_i(decId,missingOut(1))) ' or ' ...
                            bold(out_i(decId,missingOut(2))) '.  '];
                otherwise,
                    for j=1:(length(missingOut)-1)
                        str = [str bold(out_i(decId,missingOut(j))) ', '];
                    end
                    str = [str 'or ' bold(out_i(decId,missingOut(end))) '.  '];
                end
            end
        end
    end

function str = missingCondition(blkEntry,cvstruct,data)
    notTrue = [];
    notFalse = [];
    notTrueFalse = [];
    str = '';

    for i=1:length(data)
        if (data(i).trueCnts(end) == 0)
            if (data(i).falseCnts(end) == 0)
                notTrueFalse = [notTrueFalse i];
            else
                notTrue = [notTrue i];
            end
        else
            if (data(i).falseCnts(end) == 0)
                notFalse = [notFalse i];
            end
        end
    end

    if ~isempty(notTrue)
        if length(notTrue)>1
            str = [condition_list(data,notTrue) ' were never ' bold('true') '.  '];
        else
            str = [condition_list(data,notTrue) ' was never ' bold('true') '.  '];
        end
    end

    if ~isempty(notFalse)
        if length(notFalse)>1
            str = [condition_list(data,notFalse) ' were never ' bold('false') '.  '];
        else
            str = [condition_list(data,notFalse) ' was never ' bold('false') '.  '];
        end
    end

    if ~isempty(notTrueFalse)
        if length(notTrue)>1
            str = [condition_list(data,notTrueFalse) ' were never ' bold('evaluated') '.  '];
        else
            str = [condition_list(data,notTrueFalse) ' was never ' bold('evaluated') '.  '];
        end
    end

function str = condition_list(condData,idx)

    if length(idx)==1
        str = 'Condition ';
    else
        str = 'Conditions ';
    end

    switch(length(idx))
    case 1,
        %str = [str condData(idx).text];
        str = [str bold(condition_str(condData(idx).cvId))];
    case 2,
        str = [str bold(condition_str(condData(idx(1)).cvId)) ' and ' ...
                bold(condition_str(condData(idx(2)).cvId))];
%        str = [str condData(idx(1)).text ' and ' ...
%                condData(idx(2)).text];
    otherwise,
%        for j=1:(length(missingOut)-1)
%            str = [str condData(idx(j)).text ', '];
%        end
%        str = [str 'and ' condData(idx(end)).text];
        for j=1:(length(missingOut)-1)
            str = [str bold(condition_str(condData(idx(j)).cvId)) ', '];
        end
        str = [str 'and ' bold(condition_str(condData(idx(end)).cvId))];
    end


function str = missingMCDC(blkEntry,cvstruct,data)
    if length(data)==1
        str = [mcdc_uncovered_condition_list(data,1) '.  '];
    else
        str = '';
        for i= 1:length(data)
            str = [str mcdc_uncovered_condition_list(data,1) ' in ' ...
                    data(i).text '.  '];
        end
    end


function str = mcdc_uncovered_condition_list(mcdcData, index)

    numPreds = mcdcData(index).numPreds;
    missingIdx = [];
    for i=1:numPreds
        if ~(mcdcData(index).predicate(i).acheived(end))
            missingIdx = [missingIdx i];
        end
    end

    if length(missingIdx)==1
        str = 'Condition ';
    else
        str = 'Conditions ';
    end

    switch(length(missingIdx))
    case 1,
        str = [str mcdcData(index).predicate(missingIdx).text];
    case 2,
        str = [str mcdcData(index).predicate(missingIdx(1)).text, ' and ', ...
               mcdcData(index).predicate(missingIdx(2)).text];
    otherwise,
        for i=1:(length(missingIdx)-1)
            str = [str mcdcData(index).predicate(missingIdx(i)).text, ', '];
        end
        str = [str 'and ' mcdcData(index).predicate(missingIdx(end)).text];
    end

    if length(missingIdx)==1
        str = [str ' has '];
    else
        str = [str ' have '];
    end

    str = [str 'not demonstrated MCDC'];


function insert_string(infrmObj, blkEntry, htmlStr)

    [hndl,origin] = cv('get',blkEntry.cvId,'.handle','.origin');

    switch(origin)
    case 1, % Simulink
        udiObj = get_param(hndl,'Object');
    case 2, % Stateflow
        root = Stateflow.Root;
        udiObj = root.idToHandle(hndl);
    otherwise,
        udiObj = []
    end

    if ~isempty(udiObj)
        infrmObj.mapData(udiObj,['<big>' htmlStr '</big>']);
    end



% =========== HTML Utility Functions ===========

function out = str_to_html(in)
    out = strrep(in,'&','&amp;');
    out = strrep(out,'<','&lt;');
    out = strrep(out,'>','&gt;');

function out = bold(in)
    out = sprintf('<B>%s</B>',in);

function out = green(in)
    out = sprintf('<font color="darkgreen">%s</font>',in);

function out = red(in)
    out = sprintf('<font color="red">%s</font>',in);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%             COPIED FUNCTIONS FROM CVHTML                    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CR_TO_SPACE - Convert carraige returns to spaces

function out = cr_to_space(in),

    out = in;
    if ~isempty(in)
     out(in==10) = char(32);
        out=str_to_html(out);     % Fix for IceBrowser rendering problems!
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECT_TITLESTR_AND_LINK - Produce a description of
% this model node and a quoted hyperlink back to the
% model, e.g., Saturation block "Limit Ouput"

function titleStr = object_titleStr_and_link(id)

    [org,type,name,] = cv('get',id,  '.origin','.refClass', '.name');

    if (org==1)
        if (type==0)
            if( cv('get',id,'.treeNode.parent')==0 & strcmp(name,cv('get',cv('get',id,'.modelcov'),'.name')) )
                titleStr = sprintf('Model "%s"',name);
            else
                titleStr = sprintf('Subsystem "%s"',obj_diag_named_link(id));
            end
        else
            titleStr = sprintf('%s block "%s"',get_blk_typ_str(type),obj_diag_named_link(id));
        end
    elseif (org==2)
        sfClass = get_sf_class(type,id);
        titleStr = sprintf('%s "%s"',sfClass,obj_diag_named_link(id));
    else
        error('Origin not set properly');
    end


function str = sf_obj_link(sfId)
    if (sf('get',sfId,'.isa')==sf('get','default','state.isa'))
        % This is a state
        cvId = cv('find','all','slsfobj.handle',sfId);
        str = ['"' obj_diag_named_link(cvId(1)) '"'];
    else
        % This is a junction
        str = ['Junction #' num2str(sf('get',sfId,'.number'))];
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_DIAG_LINK - Create an HTML link to an object

function out = obj_diag_link(id,str),
    out = sprintf('<A href="matlab: cv(''SlsfCallback'',''reportLink'',%d);">%s</A>',id,str);  % <== MODIFIED


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_DIAG_NAMED_LINK - Create an HTML link to an object using
% the name as the label.

function out = obj_diag_named_link(id),
    str = cr_to_space(cv('get',id,'.name'));
    if length(str) > 40
        str = [str(1:40) '...'];
    end

    if (id==0)
        out = 'NA ';
    else
        out = obj_diag_link(id,str);
    end

