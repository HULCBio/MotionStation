function [ny,nu,nn,nx] = size(sys,nr)
%SIZE  size function for models.
%   [Ny,Nu,Npar] = SIZE(Mod)
%   [Ny,Nu,Npar,Nx] = SIZE(Mod) 
%
%   Ny is the number of output channels in the IDMODEL Mod.
%   Nu is the muber of input channels.
%   Npar is the nuber of free/estimated parameters in Mod.
%   Nx is the number of states. This is returned only for state-space
%      models (IDSS and IDGREY).
%
%   To access only one of the size use Ny = size(Mod,1), Nu = size(Mod,2),
%   Npar = size(Mod,3), Nx = size(Mod,4) or Ny = size(Mod,'Ny'), 
%   Nu = size(Mod,'Nu') etc.
%
%   When called with only one output argument, N = SIZE(Mod), returns
%   N = [Ny Nu Npar] or N = [Ny Nu Npar].
%
%   When called with no output argument, the information is displayed
%   in the MATLAB command window.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/10 23:17:42 $

txtflag = 0;
 
if nargout == 0 & nargin == 1
   txtflag = 1;
end
if nargin == 2 & nr == 0
txtflag = 1;
end
switch class(sys)
case 'idss'
   bs = pvget(sys,'Bs');
   cs = pvget(sys,'Cs');
   [Nx,Nu] = size(bs);
   Ny = size(cs,1);
case 'idpoly'
   nb = pvget(sys,'nb');
   Nu = size(nb,2);
   if isempty(nb),Nu = 0;end
   Ny = 1;
   Nx =[];
case 'idarx'
   nb = pvget(sys,'nb');
   na = pvget(sys,'na');
   Ny = size(na,1);
   [Nu]= size(nb,2);
   Nx =[];
case {'idgrey','idproc'}
   [a,b,c,d]=ssdata(sys);
   [Ny,Nu]=size(d);Nx=size(a,1);
   case 'idmodel'
   Nx = -1;
   Ny = length(sys.OutputName);
   Nu = length(sys.InputName);
   Npar = length(sys.ParameterVector);
end


Npar = length(sys.ParameterVector);
if nargin == 1 | txtflag
   if nargout == 1 & ~txtflag
      ny = [Ny,Nu,Npar,Nx];
      return
   elseif txtflag%nargout == 0
      if Ny>1
         yess = 's';
      else
         yess =[];
      end
      if Nu>1
         uess = 's';
      else
         uess =[];
      end
      if Nx>1
         xess = 's';
      else
         xess =[];
      end
      if Npar>1
         pess = 's';
      else
         pess =[];
      end
      
      switch class(sys)
      case {'idgrey','idss'}
         tex = sprintf(['State space model with %d output',...
               yess,', %d input',uess,', ',...
               '%d state',xess,', and %d free parameter',pess,'.'],Ny,Nu,Nx,Npar);
      case 'idarx'
         tex = sprintf(['ARX model with %d output',yess,', %d input',uess,', ',...
               'and %d free parameter',pess,'.'],Ny,Nu,Npar);
      case 'idpoly'
         tex = sprintf(['Input-output model with 1 output, %d input',uess,', ',...
               'and %d free parameter',pess,'.'],Nu,Npar);
   case 'idproc'
       tex = sprintf(['Process Model with %d output, %d input',uess,', ',...
           'and %d free parameter',pess,'.'],Ny,Nu,Npar);
case 'idmodel'
         tex = sprintf(['Idmodel with %d output',yess,' and %d input',uess,'.'],...
                 Ny,Nu);
      end
      if nargout == 0
         disp(tex)
      else
         ny = tex;
         end
      return
   else
      ny = Ny; nu = Nu; nn = Npar; nx = Nx;
   end
elseif nargin==2
   if ischar(nr)
      nr = lower(nr);
      nr = nr(1:2);
   end
   
   switch lower(nr)
   case 0
      txtflag = 1;
   case {1,'ny'}
      ny = Ny;
   case {2,'nu'}
      ny = Nu;
   case {3,'np'}
      ny = Npar;
   case {4,'nx'}
      ny =Nx;
   otherwise
      error(sprintf(['Second input argument must be an integer ',...
            'between 1 and 4 \nor any of ''Ny'', ''Nu'', ''Npar'', ''Nx''.']))
      
   end
end



