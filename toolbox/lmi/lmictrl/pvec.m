% Quantification of uncertainty on physical parameters.
%
% PVEC specifies the range of values and rates of
% variation of an uncertain or time-varying parameter
% vector
%              p = ( p1, p2, ... , pk )
% The data stored by PVEC is used in the description of
% parameter-dependent systems (see PSYS).
%
% Two types of parameter ranges can be specified:
%
% PV = PVEC('box',RANGE,RATE)
%        parameter vector valued in a box.
%        The Kx2 matrices RANGE and RATE specify the
%        lower and upper  bounds on pj and its rate of
%        variation  dpj/dt:
%
%            RANGE(j,1)  <=    pj    <=  RANGE(j,2)
%            RATE(j,1)   <=  dpj/dt  <=  RATE(j,2)
%
%        If RATE is omitted, p is assumed time-invariant.
%        Set  RATE(j,1) = -Inf and  RATE(j,2) = Inf  for
%        arbitrarily fast or discontinuous variations.
%
% PV = PVEC('pol', [V1 V2 ... VN] )
%        parameter vector valued in a polytope of the
%        parameter space. The vertices of this polytope
%        are "extremal" values  V1,V2,...,VN  of P.
%
% See also  PVINFO, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function pv=pvec(pvtype,v0,rate)


if ~(strcmp('box',pvtype) | strcmp('pol',pvtype)),
  error('unknown TYPE!');
elseif strcmp('pol',pvtype) & nargin~=2,
  error('For type ''pol'', the syntax is:  pv = pvec(''pol'', [v1 ... vn])')
elseif strcmp('box',pvtype) & ~any(nargin==[2 3]),
  error('For type ''box'', the syntax is:  pv = pvec(''box'',range,rate)')
end
if strcmp('box',pvtype), pvtype=1;
elseif strcmp('pol',pvtype), pvtype=2; end


if pvtype==1,
  if nargin==2, rate=zeros(size(v0)); end
  [k,c]=size(v0); [k1,c1]=size(rate);
  if c~=2 | c1~=2,
     error('RANGE and RATE must be Kx2 matrices if there are K parameters');
  elseif k~=k1,
     error('RANGE and RATE must have the same numbers of rows');
  elseif ~isempty(find(v0(:,1)>v0(:,2))),
     error('RANGE(j,1) > RANGE(j,2) not allowed');
  elseif ~isempty(find(rate(:,1)>rate(:,2))),
     error('RATE(j,1) > RATE(j,2) not allowed');
  end
  pv=[1;k];
  pv(1:k,2:5)=[v0 rate];

else
  [k,c]=size(v0);
  pv=[2;k];
  pv(1:k,2:c+1)=v0;
end
