function [xcand,fxcand] = candgen(nfactors,model)
%CANDGEN Generate candidate set for D-optimal design.
%   XCAND = CANDGEN(NFACTORS,MODEL) generates a candidate set
%   appropriate for a D-optimal design with NFACTORS factors and
%   the model MODEL.  The output matrix XCAND is N-by-NFACTORS,
%   with each row representing the coordinates of one of the N
%   candidate points.  MODEL can be any of the following strings:
%
%     'linear'          constant and linear terms (the default)
%     'interaction'     constant, linear, and cross product terms
%     'quadratic'       interactions plus squared terms
%     'purequadratic'   constant, linear, and squared terms
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   [XCAND,FXCAND] = CANDGEN(NFACTORS,MODEL) returns both the
%   matrix of factor values XCAND and the matrix of term values
%   FXCAND.  The latter can be input to CANDEXCH to generate the
%   D-optimal design.
%
%   The ROWEXCH automatically generates a candidate set using the
%   CANDGEN function, and creates a D-optimal design from it using
%   the CANDEXCH function.  You may prefer to call these functions
%   separately if you want to modify the default candidate set.
%
%   See also ROWEXCH, CANDEXCH, X2FX.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2003/11/01 04:25:18 $

% Get default values for optional arguments
if nargin < 2
  model = 'linear';
end

isquad = strcmp(model,'quadratic') | strcmp(model,'purequadratic') | ...
         strcmp(model,'q') | strcmp(model,'p');
islin = strcmp(model,'linear') | strcmp(model,'interaction') | ...
         strcmp(model,'l') | strcmp(model,'i');

% Generate a candidate set appropriate for this design
if (isquad)
   xcand = fullfact(3*ones(nfactors,1)) - 2;
elseif (islin)
   xcand = 2*(fullfact(2*ones(nfactors,1)) - 1.5);
elseif ~isnumeric(model)
   xcand = (fullfact(5*ones(nfactors,1)) - 3)/2;      
else
   if size(model,2)~=nfactors
      error('stats:candgen:InputSizeMismatch',...
            'MODEL matrix must have one column per factor.');
   end
   levels = 1 + max(model,[],1);
   xcand = fullfact(max(2,levels));
   colmax = max(xcand,[],1) - 1;
   xcand = -1 + 2*(xcand-1) ./ colmax(ones(size(xcand,1),1),:);
end

% Compute model term values for the candidate set
if nargout>1
   fxcand = x2fx(xcand,model);
end

