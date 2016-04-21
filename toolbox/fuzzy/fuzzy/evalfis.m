function [output,IRR,ORR,ARR] = evalfis(input, fis, numofpoints);
% EVALFIS    Perform fuzzy inference calculations.
%
%   Y = EVALFIS(U,FIS) simulates the Fuzzy Inference System FIS for the 
%   input data U and returns the output data Y.  For a system with N 
%   input variables and L output variables, 
%      * U is a M-by-N matrix, each row being a particular input vector
%      * Y is M-by-L matrix, each row being a particular output vector.
%   
%   Y = EVALFIS(U,FIS,NPts) further specifies number of sample points
%   on which to evaluate the membership functions over the input or output
%   range. If this argument is not used, the default value is 101 points.
%
%   [Y,IRR,ORR,ARR] = EVALFIS(U,FIS) also returns the following range 
%   variables when U is a row vector (only one set of inputs is applied):
%      * IRR: the result of evaluating the input values through the membership
%        functions. This is a matrix of size Nr-by-N, where Nr is the number
%        of rules, and N is the number of input variables.
%      * ORR: the result of evaluating the output values through the membership
%        functions. This is a matrix of size NPts-by-Nr*L. The first Nr
%        columns of this matrix correspond to the first output, the next Nr
%        columns correspond to the second output, and so forth.
%      * ARR: the NPts-by-L matrix of the aggregate values sampled at NPts
%        along the output range for each output.
%
%   Example:
%       fis = readfis('tipper');
%       out = evalfis([2 1; 4 9],fis)
%   This generates the response
%       out =
%   	   7.0169
%   	  19.6810
%
%   See also READFIS, RULEVIEW, GENSURF.

%   Kelly Liu, 10-10-97.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.22.2.2 $  $Date: 2004/04/10 23:15:23 $

ni = nargin;
if ni<2
   disp('Need at least two inputs');
   output=[];
   IRR=[];
   ORR=[];
   ARR=[];
   return
end

% Check inputs
if ~isfis(fis)
   error('The second argument must be a FIS structure.')
elseif strcmpi(fis.type,'sugeno') & ~strcmpi(fis.impMethod,'prod')
   warning('Implication method should be "prod" for Sugeno systems.')
end
[M,N] = size(input);
Nin = length(fis.input);
if M==1 & N==1,
   input = input(:,ones(1,Nin));
elseif M==Nin & N~=Nin,
   input = input.';
elseif N~=Nin
   error(sprintf('%s\n%s',...
      'The first argument should have as many columns as input variables and',...
      'as many rows as independent sets of input values.'))
end

% Issue warning if inputs out of range
inRange = getfis(fis,'inRange');
InputMin = min(input,[],1);
InputMax = max(input,[],1);
if any(InputMin(:)<inRange(:,1)) | any(InputMax(:)>inRange(:,2))
   warning('Some input values are outside of the specified input range.')
end

% Compute output
if ni==2
   numofpoints = 101;
end

[output,IRR,ORR,ARR] = evalfismex(input, fis, numofpoints);

