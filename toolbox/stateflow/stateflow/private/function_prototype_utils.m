function [result, varargout] = function_prototype_utils(method, varargin)

% Copyright 2003 The MathWorks, Inc.

result = [];

switch method
    case 'filter_out_line_cont'
        ptStr = varargin{1};
        [result, pS, pE] = str_filter_out_line_cont(ptStr);
        if nargout > 1
            varargout{1} = pS;
        end
        if nargout > 2
            varargout{2} = pE;
        end
    case 'compare'
        p1 = varargin{1};
        p2 = varargin{2};
        result = prototype_cmp(p1, p2);
    case 'style'
        autoP = varargin{1};
        sampleP = varargin{2};
        bySeq = 0;
        if nargin > 3
            bySeq = varargin{3};
        end
        result = mimic_style(autoP, sampleP, bySeq);
    otherwise
        disp(['Invalid method ''' method '''']);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [str, pS, pE] = str_filter_out_line_cont(str)
% This function replace line continuation with same length of spaces ' '
% For example, the following input string:
%      function y = foo(in1, ... % 1st input
%                       in2)
% will be filtered as:
%      function y = foo(in1,                                  in2)
%

[pS, pE] = regexp(str, '\.\.\.[^\n]*(\n|$)');
for i = 1:length(pS)
    str(pS(i):pE(i)) = ' ';
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pStr = unify_prototype(pStr)
% unify the representation of function prototype

pStr = str_filter_out_line_cont(pStr);
pStr = regexprep([' ' pStr ' '], '([=,()])', ' $1 '); % seperate all valid tokens
pStr = regexprep(pStr, '\s+', ' ');      % shrink whitespaces to single space
pStr = regexprep(pStr, '\( \) $', '');   % remove tailing ()

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = prototype_cmp(p1, p2)
% Compare two function prototype.
% Return true if they are the same, or vice versa

up1 = unify_prototype(p1);
up2 = unify_prototype(p2);

r = strcmp(up1, up2);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tailingStr = fetch_tailing_string(tailingMap, index, sepStr)

tailingStr = tailingMap{index, 2};

if isempty(sepStr) || sepStr == ' '
    return;
end

sepLoc = tailingMap{index, 3};
if isempty(sepLoc) || tailingMap{index, 4} ~= sepStr
    if isempty(tailingStr) || tailingStr(1) == '.';
        tailingStr = [sepStr tailingStr];
    else
        tailingStr(1) = sepStr;
    end
else
    tailingStr(sepLoc) = sepStr;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function styleP = mimic_style(autoP, sampleP, bySeq)
% Try preserve the user input style of sample prototype in auto
% constructed prototype string. For example, line continuation, comments.
% autoP MUST follow format like: [y1, y2] = foo(x1, x2) That is the 
% seperators "()[], " must immidiately follow symbols (include "=")
% and leave spaces round "=". And NO tailing "()"

% Remove heading/tailing white space. Safe to have a tailing newline
sampleP = regexprep(sampleP, '^\s*(.*?)\s*$', '$1\n');

noLcSampleP = str_filter_out_line_cont(sampleP);
onlyLcSampleP = char(sampleP - noLcSampleP + ' ');
tailingMap = construct_tailing_map(noLcSampleP, onlyLcSampleP);

styleP = '';
[s, e] = regexp(autoP, '[a-zA-Z]\w*|='); % Must be at most 1 '='

if isempty(s)
    return;
end

numSym = length(s);
numEntryTMap = size(tailingMap, 1);

% If all auto prototype symbols align with sample prototype, except
% at most one. We assume it's a var name change issued in Stateflow
if ~bySeq && numSym == numEntryTMap - 1  % number of symbols match
    bySeq = 1;  % Assume we do styling by sequential mapping
    numMisAlign = 0;
    
    for i = 1:numSym
        if ~strcmp(autoP(s(i):e(i)), tailingMap{i+1,1})
            numMisAlign = numMisAlign + 1;
        end
        if numMisAlign > 1
            bySeq = 0;
            break;
        end
    end
end

% Construt the styled prototype by mapping with the sample
if s(1) > 1
    styleP = fetch_tailing_string(tailingMap, 1, '[');
else
    styleP = fetch_tailing_string(tailingMap, 1, []);
end

autoP = [autoP ' '];
for i = 1:numSym
    symbol = autoP(s(i):e(i));
    sep = autoP(e(i)+1); % Seperator must directly follow symbol
    if bySeq
        idx = i+1;
    else
        idx = search_tailing_map(tailingMap, symbol);
    end
    
    if idx < 1 || idx > numEntryTMap
        if i == numSym
            tailingStr = autoP(e(i)+1:end-1); % NOTE: autoP gets appended ' ' before for loop
        else
            tailingStr = autoP(e(i)+1:s(i+1)-1);
        end
    else
        tailingStr = fetch_tailing_string(tailingMap, idx, sep);
    end
        
    styleP = [styleP autoP(s(i):e(i)) tailingStr];
end

% Remove heading/tailing white space.
styleP = regexprep(styleP, '^\s*(.*?)\s*$', '$1');

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function index = search_tailing_map(tailingMap, symbol)

numEntry = size(tailingMap, 1);
index = 0;

for i = 1:numEntry
    if strcmp(tailingMap{i, 1}, symbol)
        index = i;
        break;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tailingMap = construct_tailing_map(noLcSampleP, onlyLcSampleP)

% Get position for valid symbols
[s, e] = regexp(noLcSampleP, '[a-zA-Z]\w*');

% Insert position for the first "="
pEq = find(noLcSampleP == '=', 1);
if ~isempty(pEq)
    s = sort([s pEq]);
    e = sort([e pEq]);
end

% Calculate the symbol interval positions 
iS = [1 e+1];
iE = [s-1 length(noLcSampleP)];

% Construct symbol tailing table
numSym = length(s);
tailingMap = cell(numSym+1, 4);
tailingMap{1,1} = '^'; % The head string
tailingMap{1,2} = onlyLcSampleP(iS(1):iE(1));
tailingMap{1,3} = find(noLcSampleP(iS(1):iE(1)) == '[', 1);
tailingMap{1,4} = '[';
for i = 1:numSym
    idx = i+1;
    tailingMap{idx,1} = noLcSampleP(s(i):e(i));
    tailingMap{idx,2} = onlyLcSampleP(iS(idx):iE(idx));
    
    sepLoc = regexp(noLcSampleP(iS(idx):iE(idx)), '[\[\]\(\),]', 'once');
    tailingMap{idx,3} = sepLoc;
    if ~isempty(sepLoc)
        tailingMap{idx,4} = noLcSampleP(iS(idx)+sepLoc-1);
    end
end

return;
