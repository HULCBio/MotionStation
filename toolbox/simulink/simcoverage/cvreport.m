function cvreport(fileName,varargin),
%CVREPORT  Report the information in a cvdata object.
%
%   CVREPORT(FILE,DATA) Create a text report of the coverage
%   results in the cvdata object DATA.  The report will be 
%   written to FILE. If FILE is empty the report will be 
%   displayed at the command prompt. 
%
%   CVREPORT(FILE,DATA1,DATA2,...) Create a combined report
%   of several test objects.  The results from each object
%   will be displayed in a separate column.  Each data object
%   must correspond to the same root subsystem or the function 
%   will produce errors.
%
%   CVREPORT(FILE,DATA1,DATA2,...,DETAIL) Specify the detail
%   level of the report with the value of DETAIL, an integer
%   between 0 and 3.  Greater numbers indicate greater detail.
%   The default value is 2.
%
%   See also CVDATA.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.10.2.3 $  $Date: 2004/04/15 00:36:58 $

if check_cv_license==0
    error(['Failed to check out Simulink Verification and Validation license,', ...
           ' required for model coverage']);
end

%%%%%%%%%%%%%%%%%%%%%
% Check arguments
if ~ischar(fileName)
    error('File name should be a string');
end

if nargin < 2,
    error('At least one cvdata argument is needed');
end

detail = 2;

if nargin > 2
    switch(class(varargin{end})),
    case 'double'
        detail = varargin{end}
        lastTest = nargin-1;
        if length(detail)>1 | detail <0 | detail > 3
            error('Detail level should be specified as a scalar between 0 and 3.');
        end
    case 'cvdata'
        lastTest = nargin;
    otherwise,
        error('Unkown class for last input argument');
    end
else
    lastTest = nargin;
end
        
for i=2:lastTest
    if ~isa(varargin{i-1},'cvdata'),
        error(sprintf('Argument %d should be a cvdata object',i));
    end
end


%%%%%%%%%%%%%%%%%%%%%
% Make sure all cvdata 
% args are compatible
rootId = varargin{1}.rootId;

for i=3:lastTest
    if rootId~=varargin{i-1}.rootId,
        error(sprintf('Argument %d is incompatible with the preceeding cvdata arguments',i));
    end
end

%%%%%%%%%%%%%%%%%%%%%
% Open the output file.
if isempty(fileName),
    fileId = 1;
else
    fileId = fopen(fileName,'w');
    if fileId==-1
        warning('File could not be opened, sending output to screen');
        fileId = 1;
    end
end
        
    
%%%%%%%%%%%%%%%%%%%%%
% Build the decision data
% matrix.
dataMat = [];
for i=2:lastTest
    dataMat = [dataMat varargin{i-1}.metrics.decision];
end

topSlsf = cv('get',rootId,'.topSlsf');
modelcovId = cv('get',rootId,'.modelcov');

% Create a formating structure with useful constants
frmt.indentSize = 4;            % chars to indent for a subentry
frmt.baseWidth = 80;            % chars width of description text
frmt.numberColWidth = 12;       % char width of nuber column
frmt.colSpacing = 2;            % chars to separate columns
frmt.txtDetail = detail;            

% Create the report
report_slsf(fileId,topSlsf,0,frmt,dataMat);

if fileId>1,
    fclose(fileId);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Report_slsf - Recursive function to report on an
% slsf object and all of its offspring.
%

function report_slsf(file,id,indentCount,frmt,dataMat),

    persistent dcEnum;
    
    if isempty(dcEnum)
        dcEnum =  cv('Private','cv_metric_names','decision');
    end

    [totalIdx,totalCnt] = cv('MetricGet',id, dcEnum,  ...
                                        '.dataIdx.deep','.dataCnt.deep');
    
    if isempty(totalCnt) 
        totalCnt = 0;
        hits = 0;
    else
        hits = dataMat(totalIdx+1,:);
    end
    
    str = cv('TextOf',id,-1,[],frmt.txtDetail);
    format_output(file,indentCount,str,hits,totalCnt,frmt,1);

    decisions = cv('MetricGet', id, dcEnum, '.baseObjs');
    
    for d = decisions,

        % First Report the decision description
        str = cv('TextOf',d,-1,[],frmt.txtDetail);
        fprintf(file,'\n');
        format_output(file,indentCount+1,str,[],[],frmt,1);

        % Report the pathcounts for each outcome    
        [outcomes,startIdx]  = cv('get',d,'.dc.numOutcomes','.dc.baseIdx');
        
        totals = sum(dataMat((startIdx+1):(startIdx+outcomes),:));
        for i = 0:(outcomes-1);
            hits = dataMat(startIdx+i+1,:);
            str = cv('TextOf',d,i,[],frmt.txtDetail);
            format_output(file,indentCount+2,str,hits,totals,frmt,-1);
        end
    end

    children = cv('ChildrenOf',id);
    if ~isempty(children),    fprintf(file,'\n'); end
    for child = children,
        report_slsf(file,child,indentCount+1,frmt,dataMat);
    end
    fprintf(file,'\n');
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FORMAT_OUTPUT - format a single ouput entry.
%

function format_output(file,indentCount,str,hits,total,frmt,algn),
    
    str = cr_to_space(str);

    if nargin < 7
        algn = 1;
    end

    txtWidth = frmt.baseWidth - indentCount*frmt.indentSize;
    [rows,strmat] = word_wrap(str,txtWidth);    
    cWdth = frmt.numberColWidth + frmt.colSpacing;

    % Form the first row.
    indentStr = char(32*ones(1,indentCount*frmt.indentSize));
    row1str = [indentStr deblank(strmat(1,:))];
    row1str = [row1str char(32*ones(1,frmt.baseWidth-length(row1str)))];

    % Right align when needed.
    if(algn==-1)
        row1str = strjust(row1str,'right');
    end

    for i=1:length(hits),
        if (length(total)==1)
            tt = total;
        else
            tt = total(i);
        end
        coltxt = sprintf('%d/%d',hits(i),tt);
        coltxt = [char(32*ones(1,cWdth-length(coltxt))) coltxt];
        row1str = [row1str coltxt];
    end

    fprintf(file,'%s\n',row1str);
    for i=2:rows
       fprintf(file,'%s%s\n',indentStr,strmat(i,:));
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WORD_WRAP - Wrap a long string so that each row is
% no longer than maxLength. If the words in str are
% longer than length than the word will be broken into
% several lines.
%
function [rowCount,strmat] = word_wrap(str,maxLength),
    str = deblank(str);
    spaceIdx = find(str==' ');
    rowCount = 1;
    lineStart = 1;
    strLen = length(str);

    if(length(str) <= maxLength)
        strmat = str;
        return
    end

    strmat = '';
    while( (strLen+1-lineStart) > maxLength )
        lineStop = max(spaceIdx(spaceIdx<=maxLength+lineStart));
        if isempty(lineStop)
            lineStop = lineStart+maxLength-1;
            strmat = strvcat(strmat,str(lineStart:lineStop));
        else
            strmat = strvcat(strmat,str(lineStart:(lineStop-1)));
        end
        lineStart = lineStop+1;
        rowCount = rowCount+1;
    end

    strmat = strvcat(strmat,str(lineStart:end));
    
    
function out = cr_to_space(in),

    out = in;
    out(in==10) = char(32);
