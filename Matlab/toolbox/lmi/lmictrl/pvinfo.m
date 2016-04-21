% Retrieves information about a parameter vector specified
% with PVEC
%
% [TYP,K,NV] = PVINFO(PV)   returns the type ('box' or 'pol'),
%             the number K of parameters and, in the polytopic
%             case, the number NV of vertices defining the
%             polytopic parameter range.
% Box case:
% ---------
% [PMIN,PMAX,DPMIN,DPMAX] = PVINFO(PV,'par',J)
%             returns the lower and upper bounds on the range
%             and rate of variation of the J-th parameter
%
% Polytope case:
% --------------
% Vj = PVINFO(PV,'par',J)  returns the J-th vertex of the
%                          polytopic parameter range
%
% P = PVINFO(PV,'eval',COORD)
%             Returns the parameter vector value given a set of
%             polytopic coordinates.   If PV = [PV1,...,PVk]
%             and  COORD = [c1,...,ck], the result is
%                    P = c1*PV1 + ... + ck*PVk
%
%
% See also  PVEC, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [x,y,z,t]=pvinfo(pv,task,p)

if nargin<1,
   error('For correct syntaxes, type:   help pvinfo');
elseif ~any(pv(1,1)==[1 2])
   error('Unknown parameter vector type');
end


pvtype=pv(1,1);
k=pv(2,1);
nv=size(pv,2)-1;

if nargin==1,
  if nargout==0,
    if pvtype==1,
      disp(sprintf('Vector of %d parameters ranging in a box\n',k));
    else
      disp(sprintf('Vector of %d parameters ranging in a polytope with %d vertices\n',k,nv));

    end
  else
    if pvtype==1, x='box'; else x='pol'; end
    y=k; z=[];
    if pvtype==2, z=nv; end
  end

elseif strcmp(task,'par'),

  if pvtype==1,
    if nargin==2,
      x=pv(1:k,2:3); y=pv(1:k,4:5); z=[]; t=[];
    elseif p<0 | p>k,
      error(sprintf('J must be an integer between 1 and %d',k));
    else
      t=pv(p,2:5);
      x=t(1); y=t(2); z=t(3); t=t(4);
    end
  else
    l=size(pv,2)-1;
    if p<0 | p>l,
      error(sprintf('J must be an integer between 1 and %d',l));
    end
    x=pv(1:k,1+p);
    y=[]; z=[]; t=[];
  end

elseif strcmp(task,'eval'),
  np=length(p);
  if pvtype==1,
    error('Two input arguments maximum for the ''box'' type');
  elseif np~=nv,
    error(sprintf('COORD must be of length %d',nv))
  elseif min(p) < 0 | sum(p) == 0,
    error('The polytopic coordinates COORD must be nonnegative');
  end
  p=p/sum(p);
  x=pv(1:k,2:nv+1)*p(:);
  y=[]; z=[]; t=[];

end
