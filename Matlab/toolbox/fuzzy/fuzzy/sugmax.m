function out=sugmax(fis)
%SUGMAX Find maximum output range for Sugeno fuzzy system.
%   [maxOut,minOut]=SUGMAX(FIS) returns two vectors maxOut and
%   minOut that correspond to the highest and lowest possible
%   outputs for the Sugeno fuzzy inference system associated with
%   the matrix FIS, given the prescribed limits on the range of the
%   input variables. There are as many elements in maxOut and maxIn
%   as there are outputs.
%
%   For example:
%
%           a=newfis('sugtip','sugeno');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           a=addvar(a,'input','food',[0 10]);
%           a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%           a=addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%           a=addvar(a,'output','tip',[0 30]);
%           a=addmf(a,'output',1,'cheap','constant',5);
%           a=addmf(a,'output',1,'generous','constant',25);
%           ruleList=[1 1 1 1 2; 2 2 2 1 2 ];
%           a=addrule(a,ruleList);
%           sugmax(a)

%   Ned Gulley, 6-15-94
%   Revised: P. Gahinet 5/8/00
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.12.2.2 $  $Date: 2004/04/10 23:15:38 $

if ~strcmp(fis.type,'sugeno'),
    error('SUGMAX works only with Sugeno fuzzy inference systems.');
end

inRange=getfis(fis,'inRange');
outMFParams=getfis(fis,'outMFParams');
numInputs=length(fis.input);
numOutputs=length(fis.output);

out=zeros(numOutputs,2);

for outputVarIndex=1:numOutputs,
    % Loop over each output
    numOutputMFs = length(fis.output(outputVarIndex).mf);
    params = zeros(numInputs+1,numOutputMFs);
    inputValsMin = zeros(numInputs,numOutputMFs);
    inputValsMax = zeros(numInputs,numOutputMFs);
    
    for j=1:numOutputMFs,
        % Format params to represent the linear map b + sum(ai*ui)
        if strcmp(fis.output(outputVarIndex).mf(j).type,'constant')
            params(numInputs+1,j) = fis.output(outputVarIndex).mf(j).params(1);
        else
            params(:,j) = fis.output(outputVarIndex).mf(j).params(:);
        end
        % Set maximizing/minimizing input vector
        pospar = (params(1:numInputs,j)>=0);
        inputValsMax(pospar,j) = inRange(pospar,2);
        inputValsMax(~pospar,j) = inRange(~pospar,1);
        inputValsMin(pospar,j) = inRange(pospar,1);
        inputValsMin(~pospar,j) = inRange(~pospar,2);
    end
    zMax = params(numInputs+1,:) + sum(params(1:numInputs,:) .* inputValsMax);
    zMin = params(numInputs+1,:) + sum(params(1:numInputs,:) .* inputValsMin);
    out(outputVarIndex,:) = [min(zMin) max(zMax)];
end

