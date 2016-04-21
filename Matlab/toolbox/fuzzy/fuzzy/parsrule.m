function [outFis,outTxtRuleList,errorStr]=parsrule(fis,inTxtRuleList,ruleFormat,lang)
%PARSRULE Parse fuzzy rules.
%   This function parses the text that defines the rules (txtRuleList) for a 
%   fuzzy system (fis) and returns a FIS structure with the appropriate rule 
%   list in place. If the original input FIS structure, fis, has any rules 
%   initially, they are replaced in the new matrix fis2. Three different rule 
%   formats (indicated by ruleFormat) are supported: *verbose*, *symbolic*, and 
%   *indexed*. The default format is *verbose*. When the optional language 
%   argument (lang) is used, the rules are parsed in verbose mode, assuming the 
%   key words are in the language, lang. This language must be either 
%   'english', 'francais', or 'deutsch'. The key language words in English are: 
%   IF, THEN, IS, AND, OR, and NOT. 
%   
%   outFIS = PARSRULE(inFIS,inRuleList) parses the rules in the string
%   matrix inRuleList and returns the updated FIS matrix outFIS. 
%
%   outFIS = PARSRULE(inFIS,inRuleList,ruleFormat) parses the rules using
%   the given ruleFormat.
%
%   outFIS = PARSRULE(inFIS,inRuleList,ruleFormat,lang) parses the 
%   rules in verbose mode assuming the key words are in the language, lang.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addvar(a,'input','food',[0 10]);
%           a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%           a=addvar(a,'output','tip',[0 30]);
%           a=addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%           rule1='if service is poor or food is rancid then tip is cheap';
%           a=parsrule(a,rule1);
%           showrule(a)
%   
%   See also ADDRULE, RULEEDIT, SHOWRULE.

%   [outFIS,outRuleList,errorStr] = PARSRULE(...) returns the text version
%   of the newly-parsed rules. If there have been errors in the parsing,
%   the error message is returned in errorStr, and the # character is placed
%   at the beginning of the offending line in outRuleList.
%
%   Ned Gulley, 4-27-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.29 $  $Date: 2002/04/19 02:49:30 $

if nargin<3,
    ruleFormat='verbose';
end

if nargin<4,
    lang='english';
end
outTxtRuleList=[];
errorStr=[];
if ~strcmp(ruleFormat,'indexed'),
    if strcmp(lang,'english'),
        ifStr=' if ';
        andStr='and';
        orStr='or';
        thenStr='then';
        equalStr=' is ';
        isStr=' is ';
        notStr='not';
    elseif strcmp(lang,'francais'),
        ifStr=' si ';
        andStr='et';
        orStr='ou';
        thenStr='alors';
        equalStr=' est ';
        isStr=' est ';
        notStr='n''est_pas';
    elseif strcmp(lang,'deutsch'),
        ifStr=' wenn ';
        andStr='und';
        orStr='oder';
        thenStr='dann';
        equalStr=' ist ';
        isStr=' ist ';
        notStr='nicht';
    elseif strcmp(lang,'svenska'),
        ifStr=' om ';
        andStr='och';
        orStr='eller';
        thenStr='innebar_att';
        equalStr=' aer ';
        isStr=' aer ';
        notStr='inte';
    end
end

% Determine all the necessary constants
numInputs=length(fis.input);
numOutputs=length(fis.output);

for i=1:length(fis.input)
 numInputMFs(i)=length(fis.input(i).mf);
end
numOutputMFs=[];
for i=1:length(fis.output)
 numOutputMFs(i)=length(fis.output(i).mf);
end

if isempty(inTxtRuleList),
    outFis=setfis(fis,'ruleList',[]);
    return
end

% Remove any rows that are nothing but blanks
index=find(inTxtRuleList==0);
inTxtRuleList(index)=32*ones(size(index));
inTxtRuleList(all(inTxtRuleList'==32),:)=[];
if isempty(inTxtRuleList),
    outFis=setfis(fis,'ruleList',[]);
    return
end

% Replace all punctuation (and zeros) with spaces (ASCII 32)
inTxtRuleList2=inTxtRuleList;
index=[
    find(inTxtRuleList2==',')
    find(inTxtRuleList2=='#')
    find(inTxtRuleList2==':')
    find(inTxtRuleList2=='(')
    find(inTxtRuleList2==')')];
inTxtRuleList2(index)=32*ones(size(index));
inTxtRuleList2(all(inTxtRuleList2'==32),:)=[];

if isempty(inTxtRuleList2),
    outFis=setfis(fis,'ruleList',[]);
    return
end

inTxtRuleList2=setstr(inTxtRuleList2);
numRules=size(inTxtRuleList2,1);

if strcmp(ruleFormat,'symbolic'),
    symbFlag=1;
else
    symbFlag=0;
end

if strcmp(ruleFormat,'indexed'),
    ruleList=zeros(numRules,numInputs+numOutputs+2);
    errRuleIndex=[];
    goodRuleIndex=[];
    errorFlag=0;
    for ruleIndex=1:numRules,
        str=['[' inTxtRuleList2(ruleIndex,:) ']'];
        rule=eval(str,'[]');
        if isempty(rule),
            errorStr=['Rule did not evaluate properly.'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        elseif length(rule)<(numInputs+numOutputs)+2,
            errorStr=['Not enough columns for this rule. The rule is not complete.'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        elseif length(rule)>(numInputs+numOutputs)+2,
            errorStr=['Too many columns for this rule.'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        elseif any(abs(rule(1:numInputs))>numInputMFs),
            errorStr=['Input MF index is too high'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        elseif any(abs(rule((1:numOutputs)+numInputs))>numOutputMFs),
            errorStr=['Output MF index is too high'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        elseif rule(numOutputs+numInputs+1)>1 | rule(numOutputs+numInputs+1)<0,
            errorStr=['Rule weight must be between 0 and 1'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        elseif rule(numOutputs+numInputs+2)~=1 & rule(numOutputs+numInputs+2)~=2,
            errorStr=['Fuzzy operator must be either 1 (AND) or 2 (OR)'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        else
            ruleList(ruleIndex,:)=rule;
        end

        if errorFlag,
            errRuleIndex=[errRuleIndex ruleIndex];
        else
            goodRuleIndex=[goodRuleIndex ruleIndex];
        end
        errorFlag=0;
    end

else
    % symbolic format is first converted to verbose and then
    % everything is parsed as verbose text

    inLabels=lower(getfis(fis,'inLabels'));
    inMFLabels=lower(getfis(fis,'inMFLabels'));
    outLabels=lower(getfis(fis,'outLabels'));
    outMFLabels=lower(getfis(fis,'outMFLabels'));

    % String pre-processing
    % Use "lower" to make it case insensitive
    inTxtRuleList2=lower(inTxtRuleList2);

    antCode=zeros(numRules,numInputs);
    consCode=zeros(numRules,numOutputs);
    andOrCode=ones(numRules,1);
    wtCode=ones(numRules,1);

    errorFlag=0;
    errRuleIndex=[];
    goodRuleIndex=[];

    for ruleIndex=1:numRules,
        txtRule=inTxtRuleList2(ruleIndex,:);

        if symbFlag
            % If the rules are in symbolic format, a little pre-processing
            % will save the day
            txtRule=strrep(txtRule,'=>',[' ' thenStr ' ']);
            txtRule=strrep(txtRule,'&',[' ' andStr ' ']);
            txtRule=strrep(txtRule,'|',[' ' orStr ' ']);
            txtRule=strrep(txtRule,'~=',[' ' notStr ' ']);
            txtRule=strrep(txtRule,'=',' ');
        else
            txtRule=[' ' txtRule];
            txtRule=strrep(txtRule,ifStr,' ');
            txtRule=strrep(txtRule,isStr,' ');
        end

        % Compress all multiple spaces down into one space
        % This is a crucial maneuver that allows me to separate words
        % quickly and painlessly.
        spaceIndex=find(txtRule==' ');
        dblSpaceIndex=find(diff(spaceIndex)==1);
        txtRule(spaceIndex(dblSpaceIndex))=[];

        % Form the antecedent and consequent strings
        antStart=1;
        antEnd=findstr(txtRule,[' ' thenStr ' ']);
        if isempty(antEnd),
            errorStr=['Rule is not an if-then rule.'];
            if nargout<3,
                error(errorStr);
            else
                errorFlag=1;
            end
        end

        antStr=deblank(txtRule((antStart):(antEnd-1)));
        consStr=deblank(txtRule((antEnd+6):size(txtRule,2)));

        % Decode the antecedent
        spaceIndex=[findstr(antStr,' ') length(antStr)];
        if spaceIndex(1)~=1, spaceIndex=[1 spaceIndex]; end

        % Ignore the first word if it's a line number
        firstWord=antStr(spaceIndex(1):spaceIndex(2));
        if all(abs(firstWord)<58),
            % If all characters are less than ASCII 58 ('9') then it's a number,
            % so start reading from the second word.
            antPtr=2;
        else
            antPtr=1;
        end

        % You need at least two words in your antecedent in order to play
        if (length(spaceIndex)-antPtr)<2,
            errorStr=['Rule antecedent is incomplete'];
            if nargout<3, 
                error(errorStr); 
            else 
                errorFlag=1;
            end
        end                 

        while antPtr<length(spaceIndex) & ~errorFlag,
            nextWord=antStr(spaceIndex(antPtr):spaceIndex(antPtr+1));
            nextWord(find(nextWord==32))=[];
            if strcmp(nextWord,andStr),
                andOrCode(ruleIndex)=1;
            elseif strcmp(nextWord,orStr),
                andOrCode(ruleIndex)=2;
            else
                varName=nextWord;
                varIndex=findrow(varName,inLabels);
                if isempty(varIndex),
                    errorStr=['There is no input variable called ' varName];
                    if nargout<3, 
                        error(errorStr); 
                    else 
                        errorFlag=1;
                    end
                end

                antPtr=antPtr+1;
                nextWord=antStr(spaceIndex(antPtr):spaceIndex(antPtr+1));
                nextWord(find(nextWord==32))=[];
                % Handle potential usage of the word NOT
                if strcmp(nextWord,notStr),
                    MFIndexMultiplier=-1;
                    antPtr=antPtr+1;
                    nextWord=antStr(spaceIndex(antPtr):spaceIndex(antPtr+1));
                else
                    MFIndexMultiplier=1;
                end

                MFIndexBegin=sum(numInputMFs(1:(varIndex-1)))+1;
                MFIndexEnd=MFIndexBegin+numInputMFs(varIndex)-1;
                MFList=inMFLabels(MFIndexBegin:MFIndexEnd,:);
                mfIndex=findrow(nextWord,MFList)*MFIndexMultiplier;
                if isempty(mfIndex) & ~errorFlag,
                    errorStr=['There is no MF called ' nextWord ...
                        ' for the input variable ' varName];
                    if nargout<3, 
                        error(errorStr); 
                    else 
                        errorFlag=1;
                    end
                end
                if ~errorFlag,
                    antCode(ruleIndex,varIndex)=mfIndex;
                end
            end

        antPtr=antPtr+1;
        end

        % Decode the consequent
        spaceIndex=[1 findstr(consStr,' ') length(consStr)];
        consPtr=1;

        % You need at least two words in your consequent in order to play
        if (length(spaceIndex)-consPtr)<2,
            errorStr=['Rule consequent is incomplete'];
            if nargout<3, 
                error(errorStr); 
            else 
                errorFlag=1;
            end
        end                 

        while consPtr<length(spaceIndex) & ~errorFlag,
            nextWord=consStr(spaceIndex(consPtr):spaceIndex(consPtr+1));
            nextWord(find(nextWord==32))=[];

            if all((nextWord>=32) & (nextWord<=57)) & ~isempty(nextWord),
                wtCode(ruleIndex)=eval(nextWord);
            elseif ~isempty(nextWord),
                varName=nextWord;
                varIndex=findrow(varName,outLabels);
                if isempty(varIndex),
                    errorStr=['There is no output variable called ' varName];
                    if nargout<3, 
                        error(errorStr); 
                    else 
                        errorFlag=1;
                    end
                end

                consPtr=consPtr+1;
                nextWord=consStr(spaceIndex(consPtr):spaceIndex(consPtr+1));
                nextWord(find(nextWord==32))=[];
                % Handle potential usage of the word NOT
                if strcmp(nextWord,notStr),
                    MFIndexMultiplier=-1;
                    consPtr=consPtr+1;
                    nextWord=consStr(spaceIndex(consPtr):spaceIndex(consPtr+1));
                else
                    MFIndexMultiplier=1;
                end

                MFIndexBegin=sum(numOutputMFs(1:(varIndex-1)))+1;
                MFIndexEnd=MFIndexBegin+numOutputMFs(varIndex)-1;
                MFList=outMFLabels(MFIndexBegin:MFIndexEnd,:);
                mfIndex=findrow(nextWord,MFList)*MFIndexMultiplier;
                if isempty(mfIndex) & ~errorFlag,
                    errorStr=['There is no MF called ' nextWord ...
                        ' for the output variable ' varName];
                    if nargout<3, 
                        error(errorStr); 
                    else 
                        errorFlag=1;
                    end
                end
                if ~errorFlag,
                    consCode(ruleIndex,varIndex)=mfIndex;
                end
            end

        consPtr=consPtr+1;
        end
        
        if errorFlag,
            errRuleIndex=[errRuleIndex ruleIndex];
        else
            goodRuleIndex=[goodRuleIndex ruleIndex];
        end
        errorFlag=0;

    end
    ruleList=[antCode consCode wtCode andOrCode];

end    % if strcmp(ruleFormat, ...

% At this point, we're nearly done. Compile the parsed rules along with
% the rules that have been flagged with errors. Make sure and 
% don't include any error-ridden rules in the parsed output
% Get back the cleaned rules that were properly parsed

ruleList(errRuleIndex,:)=[];
outFis=setfis(fis,'ruleList',ruleList);
numRules=length(goodRuleIndex);
goodRuleList=showrule(outFis,1:numRules,ruleFormat,lang);
goodWid=size(goodRuleList,2);

numErrs=length(errRuleIndex);
errWid=0;
if numErrs>0,
    inTxtRuleList(goodRuleIndex,:)=[];
    % Replace any already existing # signs with spaces so they don't keep piling up
    inTxtRuleList(find(inTxtRuleList=='#'))= ...
        32*ones(size(find(inTxtRuleList=='#')));
    % Add new # signs to indicate the fact that there's been an error
    inTxtRuleList=[abs('#')*ones(numErrs,1) inTxtRuleList];

    % Compress all multiple spaces down into one space
    errTxtRuleList=[];
    for count=1:numErrs,
        errTxtRule=inTxtRuleList(count,:);
        spaceIndex=find(errTxtRule==' ');
        dblSpaceIndex=find(diff(spaceIndex)==1);
        errTxtRule(spaceIndex(dblSpaceIndex))=[];
        errTxtRuleList=fstrvcat(errTxtRuleList,errTxtRule);
    end;

    errTxtRuleList=setstr(errTxtRuleList);
    errWid=size(errTxtRuleList,2);
end

% Combine the good and bad lines for display
outTxtRuleList=32*ones(numRules,max(goodWid,errWid));
if ~isempty(goodRuleIndex),
    outTxtRuleList(goodRuleIndex,1:goodWid)=goodRuleList;
end
if ~isempty(errRuleIndex),
    outTxtRuleList(errRuleIndex,1:errWid)=errTxtRuleList;
end
