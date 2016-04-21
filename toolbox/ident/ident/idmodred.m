function mr=idmodred(m,order,varargin)
%IDMODRED  Reduces the order of models.
%   Requires the Control Systems Toolbox
%   MRED = IDMODRED(M,ORDER)
%
%   M: Original model as an IDMODEL (IDPOLY, IDARX, IDPOLY, or IDGREY).
%   ORDER: Desired order of reduced model.
%      If ORDER=[] (default), a plot is shown, and you are
%      prompted to select the order.
%   With MRED = IDMODRED(M,ORDER,'DisturbanceModel','None' an output error 
%   model (K = 0) is produced otherwise also the noise model is reduced.
%   MRED: The reduced order model as an IDSS model.
%
%   The routine is based on balreal and modred in the
%   Control Systems Toolbox.
%   See also BALREAL, MODRED, IDMODEL.

%   L. Ljung 10-10-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/04/06 14:22:26 $

if nargin < 1
   disp('Usage: THRED = IDMODRED(TH)')
   disp('       THRED = IDMODRED(TH,ORDER,OE)')
   disp('       OE is one of ''no_oe'', ''oe''.')
   return
end

if ~exist('balreal'),
    error('This routine requires the Control Systems Toolbox!')
end
if nargin<2,order=[];end
m1=m;
isoe = 0;
if nargin>2 % old syntax
   oe = varargin{1};
   if strcmp(lower(oe),'oe'), 
      isoe=1;
   end
end
if nargin > 3
   if strcmp(lower(varargin{1}(1)),'n')
      if strcmp(lower(varargin{2}(1)),'n')
         isoe = 1;
      end
   end
end

if isoe
   m1 = m1(:,'mea');
end
m2 = ss(m1); 
m2=minreal(m2);
[m2,g] = balreal(m2);
 %x0=t*x0;
if isempty(order)
   stem(1:length(g),log(g)),xlabel('order'),ylabel('log of weight')
   title('Select order in the Command Window')
   order=input('Type the desired order:   ');
end
mr = modred(m2,[sum(order)+1:length(g)]);
mr = idss(mr);
mr = inherit(mr,m1);
