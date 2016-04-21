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

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $

ni = nargin;
no = nargout;
error(nargchk(1,2,ni));

sizes = size(sys.num);
sizes = [sizes , ones(1,length(sizes)==3)];
nd = length(sizes);

if ni==1,
   if no==0,
      % Display only for SIZE(SYS) 
      s = 's';
      ny = sizes(1);
      nu = sizes(2);
      if nd==2,
         disp(sprintf('Transfer function with %d output%s and %d input%s.',...
            ny,s(1,ny~=1),nu,s(1,nu~=1)));
      else
         ArrayDims = sprintf('%dx',sizes(3:end));
         disp(sprintf('%s array of transfer functions',ArrayDims(1:end-1)))
         disp(sprintf('Each model has %d output%s and %d input%s.\n',...
            ny,s(1,ny~=1),nu,s(1,nu~=1)));
      end
   elseif no==1,
      % S = SIZE(SYS)
      s1 = sizes;
   else
      % [S1,..,SK] = SIZE(SYS)
      s = [sizes(1:2) sizes(3:min(nd,no-1)) prod(sizes(no:nd)) ones(1,no-nd)];
      s1 = s(1);
      varargout = num2cell(s(2:no)); 
   end

else
   % SIZE(SYS,'ORDER') or SK = SIZE(SYS,K)
   if ~ischar(x),
      if x<=0,
         error('Second argument must be a non negative integer.')
      end
      x = round(x);
      sizes = [sizes ones(1,x-nd)];
      s1 = sizes(x);
   elseif strcmp(lower(x(1:min(1,end))),'o')   
      [ro,co] = tforder(sys.num,sys.den);
      s1 = min(ro,co);   
      if length(s1) & ~any(s1(2:end)-s1(1:end-1)),
         % Uniform order
         s1 = s1(1);
      end
   else
      error('Second input argument must be an integer or the string ''order.''')
   end
   
end
      
