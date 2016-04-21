function [a,b,c,d,Ts,Td] = ssdata(sys,cellflag)
%SSDATA  Quick access to state-space data.
%
%   [A,B,C,D] = SSDATA(SYS) retrieves the matrix data A,B,C,D
%   for the state-space model SYS.  If SYS is not a state-space 
%   model, it is first converted to a state-space representation.
%
%   [A,B,C,D,TS] = SSDATA(SYS) also returns the sample time TS.
%   Other properties of SYS can be accessed with GET or by direct 
%   structure-like referencing (e.g., SYS.Ts).
%
%   For arrays of SS models with the same order (number of states), 
%   SSDATA returns multi-dimensional arrays A,B,C,D where A(:,:,k),
%   B(:,:,k), C(:,:,k), D(:,:,k) are the state-space matrices of 
%   the k-th model SYS(:,:,k).
%
%   For arrays of SS models with variable order, use the syntax
%      [A,B,C,D] = SSDATA(SYS,'cell')
%   to extract the state-space matrices of each model as separate
%   cells in the cell arrays A,B,C,D.
%
%   See also SS, GET, DSSDATA, TFDATA, ZPKDATA, LTIMODELS, LTIPROPS.

%   Author(s): P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $

% Factor in the E matrix
sizes = size(sys.d);
se = cellfun('length',sys.e);
if any(se(:)),
   for i=1:prod(size(sys.a)),
      [l,u,p] = lu(sys.e{i});
      sys.a{i} = u\(l\(p*sys.a{i}));  % a = e\a
      sys.b{i} = u\(l\(p*sys.b{i}));  % b = e\b
   end
end

% Build A,B,C,D outputs
d = sys.d;
if nargin>1,
   % Return A,B,C as cell arrays
   if ~ischar(cellflag),
      error('Second input argument must be the string ''cell''.')
   end
   a = sys.a;
   b = sys.b;
   c = sys.c;
   d = nd2cell(d,[sizes(3:end) 1 1]);
else
   % Return A,B,C as ND arrays
   try
      a = cell2nd(sys.a,0,0);
      b = cell2nd(sys.b,0,sizes(2));
      c = cell2nd(sys.c,sizes(1),0);
   catch
      % Can't represent A,B,C as ND arrays
      error('Use [A,B,C,D] = ssdata(sys,''cell'') for arrays of LTI models with varying order.')
   end
end

% Sample time
Ts = getst(sys.lti);

% Obsolete TD output
if nargout>5,
   warning('Obsolete syntax. Use the property InputDelay to access input delays.')
   Td = get(sys.lti,'InputDelay')';
end

