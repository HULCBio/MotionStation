function plotstep(plant,opt)

%PLOTSTEP Plot the step response of a system.
% 	plotstep(plant)
%  	plotstep(plant,opt)
%
% Inputs:
%  plant : description of the system in MPC step format.
%  opt   : a vector indicating which outputs to plot.
%
% See also MOD2STEP, PLOTALL, PLOTEACH, PLOTFRSP, SS2STEP,.
%	TFD2STEP, IMP2STEP

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage:  plotstep(plant,opt)');
   return
end
[nny,nu] = size(plant);
ny = plant(nny-1,1);
delt = plant(nny,1);
n = (nny-ny-2)/ny;
t = delt*[0:n]';
T = ' step response : ';

if nargin < 2
   opt=[1:ny];
elseif isempty(opt)
   opt=[1:ny];
else
   [nrow,ncol]=size(opt);
   if nrow ~= 1
      error('OPT must be a row vector')
   elseif ncol > ny
      error('OPT has too many columns')
   elseif any(opt < 1 | opt > ny)
      error('One or more elements of OPT too large or too small')
   end
end

N=nny-ny-2;
nyp=length(opt);
for iu = 1:nu
  y=reshape(plant(1:N,iu),ny,n)';
  y=[zeros(1,nyp);y(:,opt)];
  inc=0;
  while nyp > inc
    clf
    if (nyp==inc+1)
        TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+1))];
        plot(t,y(:,1+inc)), title(TYY), xlabel('TIME');
    elseif (nyp==inc+2)
        TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+1))];
        subplot(211), plot(t,y(:,1+inc)), title(TYY), xlabel('TIME');
        TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+2))];
        subplot(212), plot(t,y(:,2+inc)), title(TYY), xlabel('TIME');
    else
        TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+1))];
        subplot(221), plot(t,y(:,1+inc)), title(TYY), xlabel('TIME');
        TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+2))];
        subplot(222), plot(t,y(:,2+inc)), title(TYY), xlabel('TIME');
        TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+3))];
        subplot(223), plot(t,y(:,3+inc)), title(TYY), xlabel('TIME');
        if (nyp>=4+inc)
          TYY = ['u',int2str(iu),T,'y',int2str(opt(inc+4))];
          subplot(224), plot(t,y(:,4+inc)), title(TYY), xlabel('TIME');
        end
    end
    pause
    inc=inc+4;
  end
end

% end of function PLOTSTEP.M