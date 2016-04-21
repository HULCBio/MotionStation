function metricStruct = perform_operation(lhs_cvdata,rhs_cvdata,opStr,opChar)
%PERFORM_OPERATION - Produce the data from a binary operation on cvdata objects
%
%   METRICSTRUCT = PERFORM_OPERATION(LHS_CVDATA,RHS_CVDATA,OPSTR)  A data
%   operation expressed as the string OPSTR in the form u=f(lhs,rhs) is 
%   performed on the raw execution counts in the cvdata objects LHS_CVDATA
%   and RHS_CVDATA.  The raw counts from each metric are agregated and
%   the collection of metrics is returned in METRICSTRUCT.

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $

% NOTE: Agruments should have been verified before calling this function

metricNames = cv('Private','cv_metric_names','all');
metricStruct = [];

ref.type = '.';
ref.subs = 'rootID';
rootId = subsref(lhs_cvdata,ref);

ref.subs = 'metrics';
lhsMetrics = subsref(lhs_cvdata,ref);
rhsMetrics = subsref(rhs_cvdata,ref);

% Loop through each possible metric
for metric = metricNames(:)'

    metric = metric{1};
    
    % Get raw input data
    lhs = getfield(lhsMetrics,metric);
    rhs = getfield(rhsMetrics,metric);
    
    % Check if the operation can be performed
    if (isempty(lhs) | isempty(rhs))
        u = [];
        if (opChar == '+')
            if (isempty(lhs) & ~isempty(rhs))
                u=rhs;
            else
                if (~isempty(lhs) & isempty(rhs))
                    u=lhs;
                end; %if
            end; %if
        end; %if
        if (opChar == '-')
            if (isempty(lhs) & ~isempty(rhs))
                u=zeros(1, length(rhs));
            else
                if (~isempty(lhs) & isempty(rhs))
					u=lhs;
                end; %if
            end; %if
        end; %if
        if length(u) > 0
            if( strcmp(metric,'sigrange'))
                metricData = u;
            else
                enumVal = cv('Private','cv_metric_names',metric);
                metricData = cv('ProcessData',rootId,enumVal,u);
            end
        else
            metricData = [];
        end; %if
    else
        % Special case for MCDC coverage
        if( strcmp(metric,'mcdc'))
            u = cv('BitOp',lhs,opChar,rhs);
        elseif (strcmp(metric,'sigrange'))
            minlhs = lhs(1:2:(end-1));
            minrhs = rhs(1:2:(end-1));
            maxlhs = lhs(2:2:end);
            maxrhs = rhs(2:2:end);
            u = zeros(size(lhs));
            
            switch(opChar)
            case '+',
                u(1:2:(end-1)) = min([minlhs minrhs]'); % min
                u(2:2:end) = max([maxlhs maxrhs]'); % max
                
            case '*',
                minout = max([minlhs minrhs]')'; % min
                maxout = min([maxlhs maxrhs]')'; % max
                u(1:2:(end-1)) = minout; % min
                u(2:2:end) = maxout; % max
                infIdx = find(maxout<minout);
                if ~isempty(infIdx)
                    u(2*infIdx - 1) = inf; % min
                    u(2*infIdx) = -inf; % max
                end

            case '-',
                % This operation is not completely well defined because we
                % don't distinguish between open and closed intervals.  
                %
                % Base the result on the following axioms:
                % range - point = range
                % point - range = emppty if range overlaps, pt otherwise.
                % range - range = range difference
                % empty - anything = empty
                %
                empty_lhs = maxlhs<minlhs;
                empty_rhs = maxrhs<minrhs;
                range_lhs = maxlhs>minlhs;
                range_rhs = maxrhs>minrhs;
                
                emptyIdx = empty_lhs | (~empty_lhs & minrhs<=minlhs & maxrhs>=maxlhs);
                
                inter_min = max([minlhs minrhs]')'; % min
                inter_max = min([maxlhs maxrhs]')'; % max
                
                hasMinOverlap = inter_min==minlhs;
                hasMaxOverlap = inter_max==maxlhs;
                
                minout(hasMinOverlap) = inter_max(hasMinOverlap);
                minout(~hasMinOverlap) = minlhs(~hasMinOverlap);
                maxout(hasMaxOverlap) = inter_min(hasMaxOverlap);
                maxout(~hasMaxOverlap) = maxlhs(~hasMaxOverlap);
                
                minout(emptyIdx) = inf;
                maxout(emptyIdx) = -inf;
                
                u(1:2:(end-1)) = minout; % min
                u(2:2:end) = maxout; % max
            end
            
            
        else
            % Generic case
            eval(opStr);
        end
        enumVal = cv('Private','cv_metric_names',metric);

        % Special case for condition coverage
        if( strcmp(metric,'sigrange'))
            metricData = u;
        else
            metricData = cv('ProcessData',rootId,enumVal,u);
        end
    end
    
    metricStruct = setfield(metricStruct,metric,metricData);
end    
