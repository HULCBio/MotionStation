function outStr=showrule(fis,ruleIndex,ruleFormat,lang);
%SHOWRULE Display FIS rules.
%   SHOWRULE(FIS) displays all rules in verbose format for the 
%   fuzzy inference system associated with the matrix FIS.
%   
%   SHOWRULE(FIS,ruleIndex) displays rules specified by the
%   vector ruleIndex.
%   
%   SHOWRULE(FIS,ruleIndex,ruleFormat) displays rules using the
%   rule format specified by ruleFormat, which can be one of three
%   possibilities: 'verbose' (the default), 'symbolic' (which is
%   language neutral), and 'indexed' (for membership function index 
%   referencing).
%
%   SHOWRULE(fis,ruleIndex,ruleFormat,lang) displays the rules
%   in verbose mode assuming the key words are in the language given
%   by lang, which must be either 'english', 'francais', or 'deutsch'.
%   Key words are (in English) IF, THEN, IS, AND, OR, and NOT.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           a=addvar(a,'input','food',[0 10]);
%           a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%           a=addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%           a=addvar(a,'output','tip',[0 30]);
%           a=addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%           a=addmf(a,'output',1,'generous','trimf',[20 25 30]);
%           ruleList=[1 1 1 1 2; 2 2 2 1 2 ];
%           a=addrule(a,ruleList);
%           showrule(a,[2 1],'symbolic')
%
%   See also ADDRULE, PARSRULE, RULEEDIT.

%   Ned Gulley, 3-15-94
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.22.2.2 $  $Date: 2004/04/10 23:15:37 $

% Uncomment the line below that corresponds to your language of choice
if nargin<4,
    %lang='francais';
    %lang='deutsch';
    %lang='svenska';
    lang='english';
end

numInputs=length(fis.input);
numOutputs=length(fis.output);
for i=1:length(fis.input)
 numInputMFs(i)=length(fis.input(i).mf);
end
totalInputMFs=sum(numInputMFs);
for i=1:length(fis.output)
 numOutputMFs(i)=length(fis.output(i).mf);
end
totalOutputMFs=sum(numOutputMFs);
numRules=length(fis.rule);

if nargin<2,
    ruleIndex=1:numRules;
end
if nargin<3,
    ruleFormat='verbose';
end

% Error checking
if any(ruleIndex<=0),
    error('Rule number must be positive'); 
end

if any(ruleIndex>numRules),
    error(['There are only ',num2str(numRules),' rules']); 
end

if numRules<1,
    % If there are no rules, there is no output
    outStr=' ';
    return
end

if any(ruleIndex-floor(ruleIndex)), 
    error('Illegal rule number'); 
end
    
if strcmp(ruleFormat,'verbose') | strcmp(ruleFormat,'symbolic'),
    inLabels=getfis(fis,'inLabels');
    inMFLabels=getfis(fis,'inMFLabels');    
    outLabels=getfis(fis,'outLabels');
    outMFLabels=getfis(fis,'outMFLabels');

    % Establish appropriate typographical symbols
    lftParen='(';
    rtParen=')';
    if strcmp(ruleFormat,'verbose'),
        if strcmp(lang,'english'),
            ifStr='If ';
            andStr=' and ';
            orStr=' or ';
            thenStr='then ';
            equalStr=' is ';
            isStr=' is ';
            isnotEqualStr=' is not ';
        elseif strcmp(lang,'francais'),
            ifStr='Si ';
            andStr=' et ';
            orStr=' ou ';
            thenStr='alors ';
            equalStr=' est ';
            isStr=' est ';
            isnotEqualStr=' n''est_pas ';
        elseif strcmp(lang,'deutsch'),
            ifStr='Wenn ';
            andStr=' und ';
            orStr=' oder ';
            thenStr='dann ';
            equalStr=' ist ';
            isStr=' ist ';
            isnotEqualStr=' ist nicht ';
        elseif strcmp(lang,'svenska'),
            ifStr='Om ';
            andStr=' och ';
            orStr=' eller ';
            thenStr='innebar_att ';
            equalStr=' aer ';
            isStr=' aer ';
            isnotEqualStr=' aer inte ';
        end
    elseif strcmp(ruleFormat,'symbolic'),
        ifStr='';
        andStr=' & ';
        orStr=' | ';
        thenStr='=> ';
        equalStr='==';
        isStr='=';
        isnotEqualStr='~=';
    else
        % rule index version here (not complete yet)

    end

    ruleList=getfis(fis,'ruleList');
    inputRules=ruleList(:,1:numInputs);

    for n=1:length(ruleIndex),
        rule=ruleList(ruleIndex(n),:);
        ruleWt=rule(numInputs+numOutputs+1);
        fuzzyOpCode=rule(numInputs+numOutputs+2);
        if fuzzyOpCode==1,
        opStr=andStr;
        elseif fuzzyOpCode==2,
            opStr=orStr;
        end
        wtStr=[lftParen num2str(ruleWt) rtParen];

        ruleStr1=ifStr;
        for inCount=1:numInputs,
            % Begin with the construction of the antecedent
            SignedMFIndex = rule(inCount);
            if SignedMFIndex~=0,
                MFIndex = sum(numInputMFs(1:(inCount-1)))+abs(SignedMFIndex);
                if SignedMFIndex>0,
                    % MF use is normal
                    ruleStr1=[ruleStr1, ...
                        lftParen,deblank(inLabels(inCount,:)),equalStr, ...
                        deblank(inMFLabels(MFIndex,:)),rtParen];
                else
                    % MF use requires a NOT operator
                    ruleStr1=[ruleStr1, ...
                        lftParen,deblank(inLabels(inCount,:)),isnotEqualStr, ...
                        deblank(inMFLabels(MFIndex,:)),rtParen];
                end
                % Apply the OPERATOR if appropriate
                % (the operator goes in only if there's more to the antecedent
                if any(ruleList(ruleIndex(n),(inCount+1):numInputs)),
                    ruleStr1=[ruleStr1 opStr];
                end
            end
        end

        % Now display the consequent
        opFlag=1;
        ruleStr2=thenStr;
        for outCount=1:numOutputs,
            % Begin the construction of the consequent
            SignedMFIndex = rule(outCount+numInputs);
            if SignedMFIndex~=0,
                MFIndex = sum(numOutputMFs(1:(outCount-1)))+abs(SignedMFIndex);
                if SignedMFIndex>0,
                    % MF use is normal
                    ruleStr2=[ruleStr2, ...
                        lftParen,deblank(outLabels(outCount,:)),isStr, ...
                        deblank(outMFLabels(MFIndex,:)),rtParen];
                else
                    % MF use requires a NOT operator
                    ruleStr2=[ruleStr2, ...
                        lftParen,deblank(outLabels(outCount,:)),isnotEqualStr, ...
                        deblank(outMFLabels(MFIndex,:)),rtParen];
                end
            end
        end

        if n==1,
            outStr=[num2str(ruleIndex(n)) '. ' ruleStr1 ' ' ruleStr2 ' ' wtStr];
        else
            outStr=str2mat(outStr,[num2str(ruleIndex(n)) '. ' ...
                ruleStr1 ' ' ruleStr2 ' ' wtStr]);
        end

    end    % for n=1:length(ruleIndex) ...
    
elseif strcmp(ruleFormat,'indexed'),
    ruleList=getfis(fis,'ruleList');
    inputRules=ruleList(:,1:numInputs);
    outStr=[];
    for n=1:length(ruleIndex)
        rule=ruleIndex(n);
        
        ruleStr=[];
        for varIndex=1:numInputs,
            ruleStr=[ruleStr num2str(ruleList(rule,varIndex)) ' '];
        end
        % Remove the final space character
        ruleStr(length(ruleStr))=[];
        ruleStr=[ruleStr ', '];
        for varIndex=(1:numOutputs)+numInputs,
            ruleStr=[ruleStr num2str(ruleList(rule,varIndex)) ' '];
        end
        % Rule weights
        ruleStr=[ruleStr '(' num2str(ruleList(rule,numInputs+numOutputs+1)) ') '];
        % Fuzzy operator code
        ruleStr=[ruleStr ': ' num2str(ruleList(rule,numInputs+numOutputs+2)) ' '];

        if n==1,
            outStr=ruleStr;
        else
            outStr=str2mat(outStr,ruleStr);
        end
    end
else
    error([ruleFormat ' is an unknown rule format']);
end
