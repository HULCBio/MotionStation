function [XI,YI,XO,YO,R] = discfis(fis,numPts)
%DISCFIS Discretize a fuzzy inference system.
%   [XI,YI,XO,YO,R] = DISCFIS(fis,numPts) discretizes all the membership
%   functions for the input and output variables of the fuzzy inference
%   system called fis. The columns of XI and YI are the coordinates for the
%   input membership functions, and the columns of XO and YO are the 
%   coordinates for the output membership functions. There are numPts rows
%   in each of XI, YI, XO, and YO.
%
%   R is an indexed rule list where each element in R is a number that refers
%   to the column in XI and YI, or XO and YO, depending on whether the column
%   in question corresponds to an input variable or an output variable.

%   Ned Gulley, 9-15-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $  $Date: 2002/04/14 22:20:26 $

if nargin<2, numPts=181; end
XI=[];
YI=[];
XO=[];
YO=[];
R=[];

for i=1:length(fis.input)
 numInputMFs(i)=length(fis.input(i).mf);
end

numOutputMFs=[];
for i=1:length(fis.output)
 numOutputMFs(i)=length(fis.output(i).mf);
end
numInputs=length(numInputMFs);
numOutputs=length(numOutputMFs);

% Set up the rule matrix properly for high speed indexing
ruleList=getfis(fis,'ruleList');
numRules=size(ruleList,1);

if numRules==0,
    R=[];
else
    inputSumAdjust = cumsum(numInputMFs);
    outputSumAdjust = cumsum(numOutputMFs);

    % The last two zeros mask the last two columns of the rule list,
    % the and/or column and the rule weight column
    sumAdjust=[0 inputSumAdjust(1:numInputs-1) ...
        0 outputSumAdjust(1:numOutputs-1) 0 0];
    R=abs(ruleList)+sumAdjust(ones(numRules,1),:);

    % Reset all terms that were originally zero or negative back to that value
    % We have to make sure that any zeros or negatives in the rule list
    % remain undisturbed despite any of the transformations we performed
    R=R.*sign(ruleList);
end

% Here we're precalculating all MF x and y values for plotting later
XI=zeros(numPts,sum(numInputMFs));
YI=zeros(numPts,sum(numInputMFs));

mfTypeList=getfis(fis,'inmftypes');
mfParamsList=getfis(fis,'inmfparams');
rangeList=getfis(fis,'inrange');
for varIndex=1:numInputs,
    range=rangeList(varIndex,:);
    xPts=linspace(range(1),range(2),numPts)';
    for mfIndex=1:numInputMFs(varIndex),
        mfIndex2=sum(numInputMFs(1:(varIndex-1)))+mfIndex;
        mfType=deblank(mfTypeList(mfIndex2,:));
        mfParams=mfParamsList(mfIndex2,:);
        XI(:,mfIndex2)=xPts;
        YI(:,mfIndex2)=evalmf(xPts,mfParams,mfType);
    end
end

% XO and YO will look completely different for Mamdani and Sugeno systems
fisType=deblank(fis.type);
if strcmp(fisType,'mamdani'),
    % System is Mamdani style
    XO=zeros(numPts,sum(numOutputMFs));
    YO=zeros(numPts,sum(numOutputMFs));
    mfTypeList=getfis(fis,'outmftypes');
    mfParamsList=getfis(fis,'outmfparams');
    rangeList=getfis(fis,'outrange');
    for varIndex=1:numOutputs,
        range=fis.output(varIndex).range;
        range=rangeList(varIndex,:);
        xPts=linspace(range(1),range(2),numPts)';
        for mfIndex=1:numOutputMFs(varIndex),
            mfIndex2=sum(numOutputMFs(1:(varIndex-1)))+mfIndex;
            mfType=deblank(mfTypeList(mfIndex2,:));
            mfParams=mfParamsList(mfIndex2,:);
            XO(:,mfIndex2)=xPts;
            YO(:,mfIndex2)=evalmf(xPts,mfParams,mfType);
        end
    end
else
    % System must be Sugeno style
    XO=zeros(3,sum(numOutputMFs));
    mfTypeList=getfis(fis,'outmftypes');
    mfParamsList=getfis(fis,'outmfparams');
    for i=1:length(mfTypeList)
     if strcmp(mfTypeList(i), 'linear')
       XO=mfParamsList(:,1:(numInputs+1))';
     else
       XO=mfParamsList(:,1)';
     end
    end
end

