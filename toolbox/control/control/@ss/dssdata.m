function [a,b,c,d,e,Ts,Td] = dssdata(sys,cellflag)
%DSSDATA  Quick access to descriptor state-space data.
%
%   [A,B,C,D,E] = DSSDATA(SYS) returns the values of the A,B,C,D,E
%   matrices for the descriptor state-space model SYS (see DSS).  
%   DSSDATA is equivalent to SSDATA for regular state-space models
%   (i.e., when E=I).
%
%   [A,B,C,D,E,TS] = DSSDATA(SYS) also returns the sample time TS.
%   Other properties of SYS can be accessed with GET or by direct 
%   structure-like referencing (e.g., SYS.Ts).
%
%   For arrays of SS models with variable order, use the syntax
%      [A,B,C,D,E] = DSSDATA(SYS,'cell')
%   to extract the state-space matrices of each model as separate
%   cells in the cell arrays A,B,C,D,E.
%
%   See also GET, SSDATA, DSS, LTIMODELS, LTIPROPS.

%    Author(s): P. Gahinet, 4-1-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.19 $  $Date: 2002/04/10 06:01:55 $

sizes = size(sys.d);
se = cellfun('length',sys.e);
if ~any(se(:)),
   % Turn E matrices into identity of adequate size
   for k=1:prod(sizes(3:end)),
      sys.e{k} = eye(size(sys.a{k}));
   end
end

% Build A,B,C,D,E outputs
d = sys.d;
if nargin>1,
   % Return A,B,C,E as cell arrays
   if ~ischar(cellflag),
      error('Second input argument must be the string ''cell''.')
   end
   a = sys.a;
   e = sys.e;
   b = sys.b;
   c = sys.c;
   d = nd2cell(d,[sizes(3:end) 1 1]);
else
   % Return A,B,C as ND arrays
   try
      a = cell2nd(sys.a,0,0);
      e = cell2nd(sys.e,0,0);
      b = cell2nd(sys.b,0,sizes(2));
      c = cell2nd(sys.c,sizes(1),0);
   catch
      % Can't represent A,B,C as ND arrays
      error('Use [A,B,C,D,E] = dssdata(sys,''cell'') for arrays of LTI models with varying order.')
   end
end

% Sample time
Ts = getst(sys.lti);

% Obsolete TD output
if nargout>6,
   warning('Obsolete syntax. Use the property InputDelay to access input delays.')
   Td = get(sys.lti,'InputDelay')';
end

