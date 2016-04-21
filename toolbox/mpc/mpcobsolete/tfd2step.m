function [plant] = tfd2step(tfinal, delt2, nout,  g1, g2, g3, g4, g5, g6, g7,...
                           g8, g9, g10, g11, g12, g13, g14, g15, g16, g17,...
                           g18, g19, g20, g21, g22, g23, g24, g25)
%TFD2STEP Determines the step response model of a transfer function model.
% 	plant = tfd2step(tfinal, delt2, nout, g1)
%       plant = tfd2step(tfinal, delt2, nout, g1, ..., g25)
% The transfer function model can be continuous or discrete.
%
% Inputs:
%       tfinal:         truncation time for step response model.
%       delt2:          desired sampling interval for step response model.
%       nout:           output stability indicator. For stable systems, this
%                       argument is set equal to number of outputs, ny.
%                       For systems with one or more integrating outputs,
%                       this argument is a column vector of length ny with
%                       nout(i)=0 indicating an integrating output and
%                       nout(i)=1 indicating a stable output.
%       g1, g2,...:     SISO transfer function described above ordered
%                       to be read in columnwise (by input).  The number of
%                       transfer functions required is ny*nu. (nu=number of
%                       inputs). Limited to ny*nu <= 25.
%
% Output:
%       plant:          step response coefficient matrix in MPC step format.
%
% See also MOD2STEP, PLOTSTEP, SS2STEP.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


if nargin==0
   disp('usage: plant = tfd2step(tfinal, delt2, nout, g1,...,g25)')
   return
end

if nargin < 4
   error(' Too few input arguments.');
end
nysize=size(nout);
if min(nysize) == 0       % NOUT is empty
   ny=nargin-3;           % Note:  assumes SISO or SIMO
   nout=ones(ny,1);
elseif max(nysize) == 1 & nout ~= 0   % NOUT is a scalar, ~= 0.
   ny=nout;
   nout=ones(ny,1);
elseif min(nysize) == 1   % NOUT is a vector or a scalar zero.
   ny=length(nout);
   nout=nout(:);          % Allows either column or row vector.
else
   error('NOUT must be a scalar or vector, not a matrix.')
end

% ny is number of outputs

ng = nargin-3;
nu = ng/ny;

if fix(nu)-nu~=0
   disp(' Number of transfer functions is not a multiple of the');
          disp('number of outputs entered(TFD2STEP).');
          return;
end
if length(tfinal)~=1
   error(' The step response generation time should be a scalar.');
end
if length(delt2)~=1
   error(' The sampling time should be a scalar.');
end
if delt2<0
   error(' The sampling time should be >= 0.');
end

n = max(round(tfinal/delt2)+1,2);

G = [];
for i=1:ng
   gstring=['g',int2str(i)];
   g=eval(gstring);
   [nr,m(i)]=size(g);
   if nr~=3
      error(' Transfer functions must contain three rows.');
   end
   if g(3,1)<0
      error(' The sampling period should be >= 0');
   end
   if g(3,2)<0
      error(' The time delay should be >= 0');
   end
   if g(3,1)~=0 & (fix(g(3,2))-g(3,2))~=0
      error(' The time delay should be an integer for discrete TFs');
   end

   % check for two special cases
   if (g(1,1:m(i)-1)==[zeros(1,m(i)-1)] & g(1,m(i))==1  ...
       & g(2,1:m(i)-1)==[zeros(1,m(i)-1)] & g(2,m(i))==1);
       disp('Transfer function converted to appropriate form');
       g=[1 0; 1 0; g(3,1)  g(3,2)];
       m(i)=2;
   elseif (g(1,:)==[zeros(1,m(i))]);
       g=[0 0; 1 0; delt2 0];
       m(i)=2;
   end

   casenum=0;
   if (g(3,1)==0)
% this is a continuous transfer function that will be converted
% to a discrete transfer function, first it will be converted to
% continuous state space
        [a,b,c,d]=tf2ssm(g(1,:),g(2,:));
        casenum=1;
   end
%
   if (g(3,1)~=0 & g(3,1)~=delt2)
% this is a discrete transfer function with a sampling time
% not equal to delt2, it will be also be converted to
% continuous state space
        [a,b,c,d]=tf2ssm(g(1,:),g(2,:));
        [a,b]=d2cmp(a,b,g(3,1));
        g(3,2)=g(3,1)*g(3,2); % changes deadtime to minutes
        casenum=2;
   end
%

   if (casenum==1 | casenum==2)

% the following converts a continuous state space representation into a
% discrete transfer function form : think of the following as
% a subroutine of sorts

%***********
% Account for fractional time delay using formulas in Astrom
% and Wittenmark, 1984, pages 40-42.

      kd=fix(g(3,2)/delt2);
      del=g(3,2)-kd*delt2;
      if abs(del) < eps
         del=0;
      end
      [nord,nord] = size(a);
      s = expm([[a b]*delt2; zeros(1,nord+1)]);
      phi = s(1:nord,1:nord);
      gam = s(1:nord,nord+1);
      if del > 0,
         s = expm([[a b]*(delt2-del); zeros(1,nord+1)]);
         phi0 = s(1:nord,1:nord);
         gam0 = s(1:nord,nord+1);
         s = expm([[a b]*del; zeros(1,nord+1)]);
         phi1 = s(1:nord,1:nord);
         gam1 = s(1:nord,nord+1);
         gam1=phi0*gam1;
         phi=[  phi         gam1
             zeros(1,nord)      0  ];
         gam=[ gam0
                1  ];
         c=[c 0];
      end
% Now convert from discrete state-space to discrete
% transfer function
      if isempty(gam)
         numd=d;
         dend=1;
      else
         [numd,dend]=ss2tf2(phi,gam,c,d,1);
      end

% Add pure time delay, redefine g, g(3,2) becomes zero
      if kd > 0,
         numd=[ zeros(1,kd)    numd    ];
         dend=[   dend      zeros(1,kd)];
      end
      g = [numd;dend];
      g(3,1) = delt2;
      [nr,m(i)]=size(g);

%*********
   end     % end of the discussion of form conversion;

   G = [G g];
end

% at this point all of the transfer functions are discrete

c = 0;
step = ones(n,1);
errors = zeros(ny,nu);
int=1-all(nout);

for iu = 1:nu
    for iy = 1:ny
         pointer = sum(m(1:c+iy));
         num = G(1,pointer-m(c+iy)+1:pointer);
         den = G(2,pointer-m(c+iy)+1:pointer);
         idelay = G(3,pointer-m(c+iy) +2);
         y(:,iy) = dlsimm(num,den,step);
         if (idelay~=0)
             y(1:n,iy) = [zeros(idelay,iy); y(1:n-idelay,iy)];
         end
         ys=0;
         if sum(den)~=0
             ys = sum(num)/sum(den);
         end
         if (ys~=0)
             errors(iy,iu) = 100*(ys-y(n,iy))/ys;
         else
             errors(iy,iu) = 0;
         end
         if (int==1)
            if (nout(iy)==0 & abs(sum(den)<eps))
               for ix=1:m(c+iy)
                  deni(ix)=sum(den(1:ix));
               end
               ysi=0;
               if sum(deni)~=0
                   ysi=sum(num)/sum(deni);
                   yi=y(n,iy)-y(n-1,iy);
               end
               if (ysi~=0)
                   errori(iy,iu) = 100*(ysi-yi)/ysi;
               else
                   errori(iy,iu) = 0;
               end
               errors(iy,iu) = NaN;
            else
               errori(iy,iu) = NaN;
            end
         end
    end
    c = c + ny;
    yy = y';
    plant(:,iu) = yy(:);
end

plant = plant(ny+1:n*ny,:);
nny=ny*(n-1);
plant(nny+1:nny+ny+2,1)=[nout;ny;delt2];

fprintf(' Percent error in the last step response coefficient\n')
fprintf(' of output yi for input uj is :\n')

for iy = 1:ny
    for iu = 1:nu
        fprintf(' %6.2g%%  ',errors(iy,iu));
    end
    fprintf('\n');
end

if int==1
   fprintf(' Percent error in the final slope [S(n)-S(n-1)]\n')
   fprintf(' of integrating output yi for input uj is :\n')

   for iy = 1:ny
       for iu = 1:nu
           fprintf(' %6.2g%%  ',errori(iy,iu));
       end
       fprintf('\n');
   end
end
% end of function TFD2STEP.M
