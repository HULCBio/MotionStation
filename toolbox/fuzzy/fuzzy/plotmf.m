function [xOut,yOut]=plotmf(fis,varType,varIndex,numPts)
%PLOTMF Display all of the membership functions for a given variable.
%   PLOTMF(fismat,varType,varIndex) plots all of the membership functions
%   in the FIS called fismat associated with a given variable whose type 
%   (input or output) and index are respectively given by varType and 
%   varIndex. This function can also be used with the MATLAB function
%   subplot.
%
%   [xOut,yOut]=PLOTMF(fismat,varType,varIndex) returns the x and y data
%   points associated with the membership functions without plotting them.
%
%   PLOTMF(fismat,varType,varIndex,numPts) generates the same plot with
%   exactly numPts points plotted along the curve.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           plotmf(a,'input',1)
%
%   See also EVALMF, PLOTFIS.

%   Ned Gulley, 10-30-94, Kelly Liu  7-11-96
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/14 22:19:55 $

%====================================
if nargin<4, numPts=181; end

fisType=fis.type;

if ~strcmp(varType,'input') & (~strcmp(varType,'output') | strcmp(fisType,'sugeno'))
    error('No plots for Sugeno Output MFs')
end

if strcmp(varType, 'input')
 if isfield(fis.input(varIndex), 'mf')
   numMFs=size(fis.input(varIndex).mf, 2);
 else
   numMFs = 0;
 end
 var=fis.input(varIndex);
else
 if isfield(fis.output(varIndex), 'mf')
   numMFs=size(fis.output(varIndex).mf, 2);
 else
   numMFs=0;
 end
 var=fis.output(varIndex);
end

y=zeros(numPts,numMFs);

xPts=linspace(var.range(1),var.range(2),numPts)';
x=xPts(:,ones(numMFs,1));
for mfIndex=1:numMFs,    
    mfType=var.mf(mfIndex).type;
    mfParams=var.mf(mfIndex).params;
    y(:,mfIndex)=evalmf(xPts,mfParams,mfType);
end

if nargout<1,
    plot(x,y)

     xlabel(var.name);
    ylabel('Degree of membership')
    axis([var.range(1) var.range(2) -0.1 1.1])
    for mfIndex=1:numMFs,
        centerIndex=find(y(:,mfIndex)==max(y(:,mfIndex)));
        centerIndex=floor(mean(centerIndex));
        text(x(centerIndex,mfIndex),1.05,var.mf(mfIndex).name, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10)
    end
else
    xOut=x;
    yOut=y;
end
