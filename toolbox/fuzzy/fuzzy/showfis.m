function showfis(fis)
%SHOWFIS Display annotated FIS.
%   SHOWFIS(fismat) displays a text version of the variable
%   fismat annotated row by row, allowing you to see the 
%   significance and contents of each field of the structure.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           showfis(a)
%
%   See also GETFIS.

%   Ned Gulley, 3-15-94 Kelly Liu 10-30-97
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $  $Date: 2002/04/14 22:19:46 $

if isfield(fis, 'input')
  NumInputs=length(fis.input);
else
  NumInputs=0;
end
if isfield(fis, 'output')
 NumOutputs=length(fis.output);
else
 NumOutputs=0;
end

NumInputMFs=0;
for i=1:NumInputs
 NumInputMFs(i)=length(fis.input(i).mf);
end
totalInputMFs=sum(NumInputMFs);
NumOutputMFs=0;
for i=1:NumOutputs
 NumOutputMFs(i)=length(fis.output(i).mf);
end
totalOutputMFs=sum(NumOutputMFs);
NumRules=length(fis.rule);

disp(['1.  Name             ',fis.name]);
disp(['2.  Type             ',fis.type]);
disp(['3.  Inputs/Outputs   ',mat2str([NumInputs NumOutputs])])
disp(['4.  NumInputMFs      ',mat2str(NumInputMFs)]);
disp(['5.  NumOutputMFs     ',mat2str(NumOutputMFs)]);
disp(['6.  NumRules         ',num2str(length(fis.rule))]);
disp(['7.  AndMethod        ',fis.andMethod]);
disp(['8.  OrMethod         ',fis.orMethod]);
disp(['9.  ImpMethod        ',fis.impMethod]);
disp(['10. AggMethod        ',fis.aggMethod]);
disp(['11. DefuzzMethod     ',fis.defuzzMethod]);
if NumInputs>0,
    InLabels=getfis(fis,'InLabels');
    firstRow=12;
    dispStr=[num2str(firstRow) '. InLabels         ' InLabels(1,:)];
    for n=2:NumInputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) InLabels(n,:)]);
    end
    disp(dispStr);
end
if NumOutputs>0,
    OutLabels=getfis(fis,'OutLabels');
    firstRow=12+NumInputs;
    dispStr=[num2str(firstRow) '. OutLabels        ' OutLabels(1,:)];
    for n=2:NumOutputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) OutLabels(n,:)]);
    end
    disp(dispStr);
end
if NumInputs>0,
    InRange=getfis(fis,'InRange');
    firstRow=12+NumInputs+NumOutputs;
    dispStr=[num2str(firstRow) '. InRange          ' mat2str(InRange(1,:),4)];
    for n=2:NumInputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(InRange(n,:),4)]);
    end
    disp(dispStr);
end
if NumOutputs>0,
    OutRange=getfis(fis,'OutRange');
    firstRow=12+2*NumInputs+NumOutputs;
    dispStr=[num2str(firstRow) '. OutRange         ' mat2str(OutRange(1,:),4)];
    for n=2:NumOutputs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(OutRange(n,:),4)]);
    end
        disp(dispStr);
end
if totalInputMFs>0,
    InMFLabels=getfis(fis,'InMFLabels');
    firstRow=12+2*(NumInputs+NumOutputs);
    dispStr=[num2str(firstRow) '. InMFLabels       ' InMFLabels(1,:)];
    for n=2:totalInputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) InMFLabels(n,:)]);
    end
        disp(dispStr);
end
if totalOutputMFs>0,
    OutMFLabels=getfis(fis,'OutMFLabels');
    firstRow=12+2*(NumInputs+NumOutputs)+totalInputMFs;
    dispStr=[num2str(firstRow) '. OutMFLabels      ' OutMFLabels(1,:)];
    for n=2:totalOutputMFs,
        dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) OutMFLabels(n,:)]);
    end
    disp(dispStr);
end
if totalInputMFs>0,
    InMFTypes=getfis(fis,'InMFTypes');
    firstRow=12+2*(NumInputs+NumOutputs)+totalInputMFs+totalOutputMFs;
    dispStr=[num2str(firstRow) '. InMFTypes        ' InMFTypes(1,:)];
    for n=2:totalInputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) InMFTypes(n,:)]);
    end
        disp(dispStr);
end
if totalOutputMFs>0,
    OutMFTypes=getfis(fis,'OutMFTypes');
    firstRow=12+2*(NumInputs+NumOutputs)+2*totalInputMFs+totalOutputMFs;
    dispStr=[num2str(firstRow) '. OutMFTypes       ' OutMFTypes(1,:)];
    for n=2:totalOutputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) OutMFTypes(n,:)]);
    end
    disp(dispStr);
end
if totalInputMFs>0,
    InMFParams=getfis(fis,'InMFParams');
    firstRow=12+2*(NumInputs+NumOutputs)+2*totalInputMFs+2*totalOutputMFs;
    dispStr=[num2str(firstRow) '. InMFParams       ' mat2str(InMFParams(1,:),4)];
     for n=2:totalInputMFs,
        dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(InMFParams(n,:),4)]);
    end
    disp(dispStr);
end
if totalOutputMFs>0,
    OutMFParams=getfis(fis,'OutMFParams');
    firstRow=12+2*(NumInputs+NumOutputs)+3*totalInputMFs+2*totalOutputMFs;
    dispStr=[num2str(firstRow) '. OutMFParams      ' mat2str(OutMFParams(1,:),4)];
    for n=2:totalOutputMFs,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(OutMFParams(n,:),4)]);
    end
    disp(dispStr);
end
if NumRules>0,
    ruleList=getfis(fis,'ruleList');
    firstRow=12+2*(NumInputs+NumOutputs)+3*totalInputMFs+3*totalOutputMFs;
    dispStr=[num2str(firstRow) '. Rule Antecedent  ' mat2str(ruleList(1,1:NumInputs),4)];
    for n=2:NumRules,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(ruleList(n,1:NumInputs),4)]);
    end
    disp(dispStr);

    dispStr=[num2str(firstRow) '. Rule Consequent  ' mat2str(ruleList(1,NumInputs+1:NumInputs+NumOutputs),4)];
    for n=2:NumRules,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(ruleList(n,NumInputs+1:NumInputs+NumOutputs),4)]);
    end
    disp(dispStr);
    dispStr=[num2str(firstRow) '. Rule Weigth      ' mat2str(ruleList(1,NumInputs+NumOutputs+1),4)];
    for n=2:NumRules,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(ruleList(n,NumInputs+NumOutputs+1),4)]);
    end
    disp(dispStr);
    dispStr=[num2str(firstRow) '. Rule Connection  ' mat2str(ruleList(1,NumInputs+NumOutputs+2),4)];
    for n=2:NumRules,
    dispStr=str2mat(dispStr, ...
        [num2str(firstRow+n-1) '.' 32*ones(1,18) mat2str(ruleList(n,NumInputs+NumOutputs+2),4)]);
    end
    disp(dispStr);  
end
