function uset = randunc(N,varargin)
%RANDUNC  Randomly sample uncertain parameters.
%
%   USET = RANDUNC(N,'P1',RANGE1,'P2',RANGE2,...) generates values
%   for the parameters P1,P2,... subject to the range
%   constraints RANGE1, RANGE2, ...
%
%   The parameters P1, P2, ... are uncertain parameters in a response
%   optimization project. Each range constraint specifies lower and upper
%   bounds for the uncertain parameter value.
%
%   For a scalar-valued parameter, p, specify the range as [Min,Max] or
%   {Min,Max}. The interpretation is then
%     Min <= p <= Max.
%
%   For vector- or matrix-valued parameters, specify the range as {Min,Max}
%   where Min and Max are commensurate vectors or matrices. The
%   interpretation is then
%     Min(i,j) <= p(i,j) <= Max(i,j)
%
%   The set of uncertain parameter values consists of
%      * All vertices of the parameter box specified by the upper and
%        lower bounds (2^S values if S parameters)
%      * N randomly picked points inside the parameter box.
%
%   To optimize the responses based on uncertain parameter values, set the
%   Optimized property of the uncertain parameter object, USET, to true (by
%   default this value is set to false).
%
%   Use the SETUNC function to set the uncertain parameter values within
%   the response optimization project.
%   
%   Example:
%     uset1=randunc(4,'P',{1,4},'I',{0.1,0.3},'D',{30,40})
%
%     uset2=randunc(10,'Kp',{[1,4,3,0],[4,10,7.5,6]},'Kd',{[2,2],[8,7]})
%
%   See also GRIDUNC, RESPONSEOPTIMIZER/SETUNC.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/19 01:33:51 $
%   Copyright 1990-2003 The MathWorks, Inc.
ni = length(varargin);
ParNames = varargin(1:2:ni);
if rem(ni,2)~=0
   error('Expects an odd number of inputs.')
elseif ~iscellstr(ParNames)
   error('Parameter names must be strings.')
end
npars = length(ParNames);

% Construct data set
uset = ResponseOptimizer.ParamSet(ParNames);

% Unpack range info
bnds = cell(2,npars);  % min/max/scalar
for ct=1:npars
   b = varargin{2*ct};
   if isreal(b) && numel(bnds)==2
      b = {b(1) , b(2)};
   end
   if numel(b)==2 && isa(b,'cell') && ...
         isreal(b{1}) && isreal(b{2}) && isequal(size(b{1}),size(b{2}))
      bnds(:,ct) = b(:);
   else
      error('Invalid range setting for parameter %s.',ParNames{ct})
   end
end

% Construct set of vertices
v = bnds(:,1);
for ct=2:npars
   nv = size(v,1);
   lb = bnds(1,ct);
   ub = bnds(2,ct);
   v = [v lb(ones(nv,1),:);v ub(ones(nv,1),:)];
end

% Generate random points
for ct=1:npars
   lb = bnds{1,ct};
   ub = bnds{2,ct};
   if isscalar(lb) && isscalar(ub)
      % Scalar parameter
      s = lb + rand(N,1) .* (ub-lb);
      uset.(ParNames{ct}) = cat(1,v{:,ct},s);
   else
      % Vector or matrix-valued parameters
      s = cell(N,1);
      for cts=1:N
         s{cts} = lb + rand(size(lb)) .* (ub-lb);
      end
      uset.(ParNames{ct}) = [v(:,ct) ; s];
   end
end
uset.Optimized = false;
