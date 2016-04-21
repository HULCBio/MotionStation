function nntobsu(fcn,varargin)
%NNTOBSU Warn that a function use is obsolete.
%
%  nntobsu(fcnName,line1,line2,...)
%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

global NNTWARNFLAG;
if isempty(NNTWARNFLAG)
  disp(' ')
  disp(['*WARNING* ' upper(fcn) ' used in an obsolete way.'])
  for i=1:length(varargin)
  disp(['          ' varargin{i}])
  end
  disp(['          Type NNTWARN OFF to suppress NNT warning messages.'])
  disp(' ')
elseif strcmp(NNTWARNFLAG,'error')
  error([upper(fcn) ' is used in an obsolete way.'])
end
