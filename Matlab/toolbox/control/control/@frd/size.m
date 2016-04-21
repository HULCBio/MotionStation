function [s1,varargout] = size(sys,x) 
%SIZE  Size and order of LTI models.
%
%   D = SIZE(SYS) returns
%      * the two-entry row vector D = [NY NU] for a single LTI model 
%        SYS with NY outputs and NU inputs
%      * the row vector D = [NY NU S1 S2 ... Sp] for a S1-by-...-by-Sp 
%        array of LTI models with NY outputs and NU inputs.
%   SIZE(SYS) by itself makes a nice display.
%
%   [NY,NU,S1,...,Sp] = SIZE(SYS) returns
%      * the number of outputs NY
%      * the number of inputs NU 
%      * the LTI array sizes S1,...,Sp (for arrays of LTI models)
%   in separate output arguments.  Alternatively,
%      NY = SIZE(SYS,1)   returns just the number of outputs.
%      NU = SIZE(SYS,2)   returns just the number of inputs.
%      Sk = SIZE(SYS,2+k) returns the length of the k-th LTI array 
%                         dimension.
%
%   NS = SIZE(SYS,'order') returns the model order (number of states 
%   for state-space models).  For LTI arrays, NS is scalar when all
%   models have the same order, and is an array listing the order of
%   each model otherwise.
%
%   For FRD models,
%      NF = SIZE(SYS,'freq') 
%   returns the number of frequency points.
%
%   See also NDIMS, ISEMPTY, ISSISO, LTIMODELS.

%   Author(s): S. Almy, A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 06:16:43 $

numIn = nargin;
numOut = nargout;
error(nargchk(1,2,numIn));

numFreqPoints = length(sys.Frequency);
sizes = size(sys.ResponseData);
sizes(3:min(3,end)) = [];  % ignore frequency dimension
sizes = [sizes , ones(1,length(sizes)==3)];

numDim = length(sizes);

% Construct output
if numIn==2,
   error(nargchk(0,1,numOut));
   if ischar(x)
      if strncmpi(x,'frequency',length(x))
         s1 = numFreqPoints;
      elseif strncmpi(x,'order',length(x))
         error('Second input argument ''order'' unsupported in SIZE for FRD models.');
      else
         error('Second input argument must be an integer or the string ''frequency''.');
      end
   elseif x>numDim
      s1 = 1;
   elseif x<1
      error('Second argument must be a positive integer.')
   else
      s1 = sizes(x);
   end
   
elseif numOut==0,
   % SIZE(SYS)
   if all(sizes==0)
      disp('Empty FRD model.')
      return
   elseif numDim<3,
      outputString = sprintf('FRD model with %d output(s) and %d input(s),',...
         sizes(1),sizes(2));
      disp(sprintf('%s at %d frequency point(s).\n',outputString,numFreqPoints));
   else
      ArrayDims = sprintf('%dx',sizes(3:end));
      outputString = sprintf('%s array of FRD models.\n',ArrayDims(1:end-1));
      outputString = sprintf('%sEach model has %d output%s and %d input%s,',outputString, ...
         sizes(1),repmat('s',[1 sizes(1)~=1]),sizes(2),repmat('s',[1 sizes(2)~=1]));
      disp(sprintf('%s at %d frequency point%s.\n',outputString,numFreqPoints,repmat('s',[1 numFreqPoints~=1])));
   end
elseif numOut==1,
   % S = SIZE(SYS)
   s1 = sizes;
else
   % [S1,..,SK] = SIZE(SYS)
   s = [sizes(1:2) sizes(3:min(numDim,numOut-1)) prod(sizes(numOut:numDim)) ones(1,numOut-numDim)];
   s1 = s(1);
   varargout = num2cell(s(2:numOut)); 
end
