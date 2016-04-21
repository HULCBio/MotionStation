function [newfis,errorStr]=convertfis(fis)
%CONVERTFIS convert v1 fis matrix to v2 fis structure.

%   See also READFIS.

%   Kelly Liu 5-9-97
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:22:15 $


errorStr=[];

if nargin<1,
    errorStr='No FIS matrix provided.';
    error(errorStr);
    return
end

newfis.name=getfisold(fis, 'name');

newfis.type=getfisold(fis,'type');
newfis.andMethod=getfisold(fis,'andMethod');

newfis.orMethod=getfisold(fis,'orMethod');

newfis.impMethod=getfisold(fis,'impMethod');

newfis.aggMethod=getfisold(fis,'aggMethod');

newfis.defuzzMethod=getfisold(fis,'defuzzMethod');

numInputs=getfisold(fis,'numinputs');
numInputMFs=getfisold(fis,'numinputmfs');
inLabels=getfisold(fis,'inLabels');
inRange=getfisold(fis,'inRange');
inMFLabels=getfisold(fis,'inMFLabels');
inMFTypes=getfisold(fis,'inMFTypes');
%inMFParams=getfisold(fis,'inMFParams');
numOutputs=getfisold(fis,'numoutputs');
numOutputMFs=getfisold(fis,'numoutputmfs');
outLabels=getfisold(fis,'outLabels');
outRange=getfisold(fis,'outRange');
outMFLabels=getfisold(fis,'outMFLabels');
outMFTypes=getfisold(fis,'outMFTypes');
%outMFParams=getfisold(fis,'outMFParams');

for varIndex=1:numInputs,
    newfis.input(varIndex).name=deblank(inLabels(varIndex,:));
    newfis.input(varIndex).range=inRange(varIndex,:);
    for mfIndex=1:numInputMFs(varIndex),
        MFIndex2=sum(numInputMFs(1:(varIndex-1)))+mfIndex;
        newfis.input(varIndex).mf(mfIndex).name=deblank(inMFLabels(MFIndex2,:));
        newfis.input(varIndex).mf(mfIndex).type=deblank(inMFTypes(MFIndex2,:));
        p=getfisold(fis,'input',varIndex,'MF',mfIndex,'params');
        newfis.input(varIndex).mf(mfIndex).params=p;
    end
end

for varIndex=1:numOutputs,
    newfis.output(varIndex).name=deblank(outLabels(varIndex,:));
    newfis.output(varIndex).range=outRange(varIndex,:);
    for mfIndex=1:numOutputMFs(varIndex),
        MFIndex2=sum(numOutputMFs(1:(varIndex-1)))+mfIndex;
        newfis.output(varIndex).mf(mfIndex).name=deblank(outMFLabels(MFIndex2,:));
        newfis.output(varIndex).mf(mfIndex).type=deblank(outMFTypes(MFIndex2,:));
        p=getfisold(fis,'output',varIndex,'MF',mfIndex,'params');
        newfis.output(varIndex).mf(mfIndex).params=p;
    end
end

    numRules=getfisold(fis,'numRules');

    ruleList=getfisold(fis,'ruleList');
for ruleIndex=1:numRules,
    newfis.rule(ruleIndex).antecedent=ruleList(ruleIndex, 1:numInputs);
    newfis.rule(ruleIndex).consequent=ruleList(ruleIndex, 1+numInputs:numInputs+numOutputs);
    newfis.rule(ruleIndex).weight=ruleList(ruleIndex, 1+numInputs+numOutputs:1+numInputs+numOutputs);
    newfis.rule(ruleIndex).connection=ruleList(ruleIndex, 2+numInputs+numOutputs:end);

end

