function fismat = genfis2(Xin,Xout,radii,xBounds,options)
%GENFIS2 Generates a Sugeno-type FIS using subtractive clustering.
%
%   Given separate sets of input and output data, GENFIS2 generates a fuzzy
%   inference system (FIS) using fuzzy subtractive clustering. GENFIS2 can be
%   used to generate an initial FIS for ANFIS training by first applying
%   subtractive clustering on the data. GENFIS2 accomplishes this by extracting
%   a set of rules that models the data behavior. The rule extraction method
%   first uses the SUBCLUST function to determine the number of rules and
%   antecedent membership functions and then uses linear least squares
%   estimation to determine each rule's consequent equations.
%
%   FIS = GENFIS2(XIN,XOUT,RADII) returns a Sugeno-type FIS given input data XIN
%   and output data XOUT. The matrices XIN and XOUT have one column per FIS 
%   input and output, respectively. RADII specifies the range of influence of
%   the cluster center for each input and output dimension, assuming the data 
%   falls within a unit hyperbox (range [0 1]). Specifying a smaller cluster
%   radius will usually yield more, smaller clusters in the data, and hence more
%   rules. When RADII is a scalar it is applied to all input and output
%   dimensions. When RADII is a vector, it has one entry for each input and
%   output dimension.
%
%   FIS = GENFIS2(...,XBOUNDS) also specifies a matrix XBOUNDS used to normalize
%   the data XIN and XOUT into a unit hyperbox (range [0 1]). XBOUNDS is size 
%   2-by-N, where N is the total number of inputs and outputs. Each column of
%   XBOUNDS provides the minimum and maximum values for the corresponding input
%   or output data set. If XBOUNDS is an empty matrix or not provided, the
%   minimum and maximum data values found in XIN and XOUT, are used as defaults.
%
%   FIS = GENFIS2(...,XBOUNDS,OPTIONS) specifies options for changing the
%   default algorithm parameters, type HELP SUBCLUST for details.
%
%   Examples
%       Xin1 =  7*rand(50,1);
%       Xin2 = 20*rand(50,1)-10;
%       Xin  = [Xin1 Xin2];
%       Xout =  5*rand(50,1);
%       fis = genfis2(Xin,Xout,0.5) specifies a range of influence of 0.5 for
%       all data dimensions.
%
%       fis = genfis2(Xin,Xout,[0.5 0.25 0.3]) specifies the ranges of influence
%       in the first, second, and third data dimensions are 0.5, 0.25, and 0.3
%       times the width of the data space, respectively.
%
%       fis = genfis2(Xin,Xout,0.5,[0 -10 0; 7 10 5]) specifies the data in
%       the first column of Xin are scaled from [0 7], the data in the
%       second column of Xin are scaled from [-10 10], and the data in Xout are
%       scaled from [0 5].
%
%   See also SUBCLUST, GENFIS1, ANFIS.

%   Steve Chiu, 1-25-95  Kelly Liu 4-10-97
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/14 22:21:28 $

%   Reference
%   S. Chiu, "Fuzzy Model Identification Based on Cluster Estimation," J. of
%   Intelligent & Fuzzy Systems, Vol. 2, No. 3, 1994.

[numData,numInp] = size(Xin);
[numData2,numOutp] = size(Xout);

if numData ~= numData2
    % There's a mismatch in the input and output data matrix dimensions
    if numData == numOutp
        % The output data matrix should have been transposed, we'll fix it
        Xout = Xout';
        numOutp = numData2;
    else
        error('Mismatched input and output data matrices');
    end
end

if nargin < 5
    verbose = 0;
    if nargin < 4
        xBounds = [];
    end
    [centers,sigmas] = subclust([Xin Xout],radii,xBounds);
else
    verbose = options(4);
    [centers,sigmas] = subclust([Xin Xout],radii,xBounds,options);
end


if verbose
    disp('Setting up matrix for linear least squares estimation...');
end

% Discard the clusters' output dimensions
centers = centers(:,1:numInp);
sigmas = sigmas(:,1:numInp);

% Distance multipliers
distMultp = (1.0 / sqrt(2.0)) ./ sigmas;

[numRule,foo] = size(centers);
sumMu = zeros(numData,1);
muVals = zeros(numData,1);
dxMatrix = zeros(numData,numInp);
muMatrix = zeros(numData,numRule * (numInp + 1));

for i=1:numRule

    for j=1:numInp
        dxMatrix(:,j) = (Xin(:,j) - centers(i,j)) * distMultp(j);
    end

    dxMatrix = dxMatrix .* dxMatrix;
    if numInp > 1
        muVals(:) = exp(-1 * sum(dxMatrix'));
    else
        muVals(:) = exp(-1 * dxMatrix');
    end

    sumMu = sumMu + muVals;

    colNum = (i - 1)*(numInp + 1);
    for j=1:numInp
        muMatrix(:,colNum + j) = Xin(:,j) .* muVals;
    end

    muMatrix(:,colNum + numInp + 1) = muVals;

end % endfor i=1:numRule

sumMuInv = 1.0 ./ sumMu;
for j=1:(numRule * (numInp + 1))
    muMatrix(:,j) = muMatrix(:,j) .* sumMuInv;
end

if verbose
    disp('Solving linear least squares estimation problem...');
end

% Compute the TSK equation parameters
outEqns = muMatrix \ Xout;

% Each column of outEqns now contains the output equation parameters
% for an output variable.  For example, if output variable y1 is given by
% the equation y1 = k1*x1 + k2*x2 + k3*x3 + k0, then column 1 of
% outEqns contains [k1 k2 k3 k0] for rule #1, followed by [k1 k2 k3 k0]
% for rule #2, etc.

if verbose
    disp('Creating FIS matrix...');
end

% Find out the number of digits required for printing out the input,
% output, and rule numbers
numInDigit = floor(log10(numInp)) + 1;
numOutDigit = floor(log10(numOutp)) + 1;
numRuleDigit = floor(log10(numRule)) + 1;

% Find out the required size of the FIS matrix
numRow = 11 + (2 * (numInp + numOutp)) + (3 * (numInp + numOutp) * numRule);
numCol = numInp + numOutp + 2;      % number of columns required for the rule list  
strSize = 3 + numInDigit + numOutDigit; % size of name 'sug[numInp][numOutp]'
numCol = max(numCol,strSize);
strSize = 4 + numInDigit + numRuleDigit;    % size of 'in[numInp]mf[numRule]'
numCol = max(numCol,strSize);
strSize = 5 + numOutDigit + numRuleDigit;   % size of 'out[numOutp]fm[numRule]'
numCol = max(numCol,strSize);
numCol = max(numCol,7); % size of 'gaussmf' is 7


% Set the FIS name as 'sug[numInp][numOutp]'
theStr = sprintf('sug%g%g',numInp,numOutp);
fismat.name=theStr;
% FIS type
fismat.type = 'sugeno';
% Number of inputs and outputs
%fismat(3,1:2) = [numInp numOutp];
% Number of input membership functions
%fismat(4,1:numInp) = numRule * ones(1,numInp);
% Number of output membership functions
%fismat(5,1:numOutp) = numRule * ones(1,numOutp);
% Number of rules
%fismat(6,1) = numRule;
% Inference operators for and, or, imp, agg, and defuzz(???in this order, kliu)
fismat.andMethod = 'prod';
fismat.orMethod = 'probor';
fismat.impMethod = 'min';
fismat.aggMethod = 'max';
fismat.defuzzMethod = 'wtaver';

rowIndex = 11;
% Set the input variable labels
for i=1:numInp
    theStr = sprintf('in%g',i);
    strSize = length(theStr);
    fismat.input(i).name = theStr;
end

% Set the output variable labels
for i=1:numOutp
    theStr = sprintf('out%g',i);
    strSize = length(theStr);
    fismat.output(i).name = theStr;
end

% Set the input variable ranges
if length(xBounds) == 0
    % No data scaling range values were specified, use the actual minimum and
    % maximum values of the data.
    minX = min(Xin);
    maxX = max(Xin);
else
    minX = xBounds(1,1:numInp);
    maxX = xBounds(2,1:numInp);
end
ranges = [minX ; maxX]';
for i=1:numInp
   fismat.input(i).range = ranges(i,:);
end

% Set the output variable ranges
if length(xBounds) == 0
    % No data scaling range values were specified, use the actual minimum and
    % maximum values of the data.
    minX = min(Xout);
    maxX = max(Xout);
else
    minX = xBounds(1,numInp+1:numInp+numOutp);
    maxX = xBounds(2,numInp+1:numInp+numOutp);
end
ranges = [minX ; maxX]';
for i=1:numOutp
   fismat.output(i).range = ranges(i,:);
end

% Set the input membership function labels
for i=1:numInp
    for j=1:numRule    
        theStr = sprintf('in%gmf%g',i,j);
        fismat.input(i).mf(j).name = theStr;
    end
end

% Set the output membership function labels
for i=1:numOutp
    for j=1:numRule       
        theStr = sprintf('out%gmf%g',i,j);
        fismat.output(i).mf(j).name = theStr;
    end
end

% Set the input membership function types
for i=1:numInp 
   for j=1:numRule
      fismat.input(i).mf(j).type = 'gaussmf';
   end   
end

% Set the output membership function types
for i=1:numOutp
   for j=1:numRule
      fismat.output(i).mf(j).type = 'linear';
   end   
end

% Set the input membership function parameters
colOfOnes = ones(numRule,1);    % a column of ones
for i=1:numInp
   for j=1:numRule
      fismat.input(i).mf(j).params = [sigmas(i) centers(j, i)];
   end
end
% Set the output membership function parameters
for i=1:numOutp
   for j=1:numRule
      outParams = reshape(outEqns(:,i),numInp + 1,numRule);
      fismat.output(i).mf(j).params = outParams(:,j)';
   end
end

% Set the membership function pointers in the rule list
colOfEnum = [1:numRule]';

for j=1:numRule
   for i=1:numInp
      fismat.rule(j).antecedent(i)=colOfEnum(j);
   end
   for i=1:numOutp   
      fismat.rule(j).consequent(i) = colOfEnum(j);
   end
   
  % Set the antecedent operators and rule weights in the rule

   fismat.rule(j).weight=1;
   fismat.rule(j).connection=1;
end

