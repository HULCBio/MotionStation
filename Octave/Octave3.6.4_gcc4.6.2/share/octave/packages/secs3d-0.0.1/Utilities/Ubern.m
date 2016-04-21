%% Copyright (C) 2004,2007,2008,2009,2010,2011  Carlo de Falco
%%
%% This file is part of:
%%     secs3d - A 3-D Drift--Diffusion Semiconductor Device Simulator 
%%
%%  secs3d is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  secs3d is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with secs3d; If not, see <http://www.gnu.org/licenses/>.
%%
%%  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

%
% [bp,bn]=Ubern(x)
%
% calcola la funzione di Bernoulli
% B(x)=x/(exp(x)-1) in corrispondenza dei 
% due argomenti Z e -Z, ricordando che risulta
% B(-Z)=Z+B(Z)
%

function [bp,bn]=Ubern(x)

xlim=1e-2;
ax=abs(x);

%
% Calcola la funz. di Bernoulli per x=0
%

if (ax == 0)
  bp=1.;
  bn=1.;
  return
end;

%
% Calcola la funz. di Bernoulli per valori
% asintotici dell'argomento
%

if (ax > 80),
  if (x >0),
    bp=0.;
    bn=x;
    return
  else
    bp=-x;
    bn=0.;
    return
  end;
end;

%
% Calcola la funz. di Bernoulli per valori
% intermedi dell'argomento
%

if (ax > xlim),
  bp=x/(exp(x)-1);
  bn=x+bp;
  return
else

  %
  % Calcola la funz. di Bernoulli per valori
  % piccoli dell'argomento mediante sviluppo
  % di Taylor troncato dell'esponenziale
  %
  ii=1;
  fp=1.;
  fn=1.;
  df=1.;
  segno=1.;
  while (abs(df) > eps),
    ii=ii+1;
    segno=-segno;
    df=df*x/ii;
    fp=fp+df;
    fn=fn+segno*df;
    bp=1./fp;
    bn=1./fn;
  end;
  return
end


