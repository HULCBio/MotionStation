function [N,ny,nu,ne]=size(dat,dim)
% SIZE  Size of IDDATA data sets
%
% [N,NY,NU,NE] = SIZE(DAT)
%     Returns the number of data (N), the number of outputs (NY),
%     the number of inputs (NU), and the number of exeriments (NE).
%     For multiple expriments, N is a row vector, containing the number
%     of data in each experiment.
%
%     SIZE(DAT) by itself displays the information.
%
%     N = SIZE(DAT,1)  or N = SIZE(DAT,'N');
%     NY = SIZE(DAT,2) or NY = SIZE(DAT,'NY');
%     NU = SIZE(DAT,3) or NU = SIZE(DAT,'NU');
%     NE = SIZE(DAT,4) or NE = SIZE(DAT,'NE');
%
%     Nn = SIZE(DAT) returns Nn = [N,Ny,Nu] for single experiments and
%          Nn = [sum(N),Ny,Nu,Ne] for multiple experiments.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/04/06 14:22:02 $

y = dat.OutputData;
u = dat.InputData;
ne = length(y);
ny = size(y{1},2);
nu = size(u{1},2);

for kk=1:ne
   N1(kk) = size(y{kk},1);
end
if nargout == 0&nargin == 1
   if ny>1, apy='s';else apy=[];end
   if nu>1, apu='s';else apu=[];end

disp(sprintf(['Data set with ',int2str(ny),' output',apy,...
      ' and ',int2str(nu),' input',apu,'.']))
if ne>1
   nl = [];
   for kk=1:ne
      nl=[nl,' ',int2str(N1(kk)),','];
      if kk==ne-1
         nl=[nl,' and'];
       end
   end
   nl=[nl,' resp.,'];
   disp(sprintf(['The set contains ',int2str(ne),' experiments with',nl,' data points each.']))
else
   disp(sprintf(['The number of data points is ',int2str(N1)]))
end
return
end
N=N1;
if nargout ==1&nargin==1
   if ne >1
      N = [sum(N) ny nu ne]; 
   else
      N = [N ny nu];
      end
   return
   end

if nargin==2
   dim=lower(dim);
   switch dim
   case {2,'ny'}
      N = ny;
   case {3,'nu'}
      N = nu;
   case {4,'ne'}
      N = ne;
   end
end

      
