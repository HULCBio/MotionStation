% delta = udiag(d1,d2,....)
%
% Gathers the uncertainty blocks  D1, D2, ...  into
% a single block-diagonal structure
%
%                 [   D1   0   ...    0  ]
%                 [   0    D2   0     0  ]
%      DELTA  =   [   :    0    .     :  ]
%                 [   :           .      ]
%                 [   0   ...         Dn ]
%
% Each block  Dj  is either an individual block created
% with  UBLOCK,  or a block-diagonal matrix of such
% blocks formed with  UDIAG.
% The number of input arguments is limited to 10.
%
% WARNING:  make sure that the ordering of D1, D2,... is
%           consistent with the ordering of the plant
%           inputs and outputs.
%
%
% See also  UBLOCK, UINFO, SLFT.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function delta = udiag(b1,b2,b3,b4,b5,b6,b7,b8,b9,b10)

if nargin > 10,
  error('Maximum of 10 input arguments');
end

delta=[];
for i=1:nargin,
  eval(['blck=b' num2str(i) ';']);
  c=size(delta,2);
  delta(1:size(blck,1),c+1:c+size(blck,2))=blck;
end
