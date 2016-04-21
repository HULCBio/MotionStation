function [bp,bn]=Ubern(x)
%
% [bp,bn]=Ubern(x)
%
% calcola la funzione di Bernoulli
% B(x)=x/(exp(x)-1) in corrispondenza dei
% due argomenti Z e -Z, ricordando che risulta
% B(-Z)=Z+B(Z)
%

% This file is part of
%
%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004-2006  Carlo de Falco
%
%
%
%  SECS2D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  SECS2D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.

xlim= 1e-2;
ax  = abs(x);
bp  = zeros(size(x));
bn  = bp;

block1  = find(~ax);
block21 = find((ax>80)&x>0);
block22 = find((ax>80)&x<0);
block3  = find((ax<=80)&(ax>xlim));
block4  = find((ax<=xlim)&(ax~=0));



%
% Calcola la funz. di Bernoulli per x=0
%
% if (ax == 0)
%fprintf(1,' -> executing block 1\n');
bp(block1)=1.;
bn(block1)=1.;
%end;

%
% Calcola la funz. di Bernoulli per valori
% asintotici dell'argomento
%
% if (ax > 80),
% fprintf(1,' -> eexecuting block 2\n');
% if (x >0),
bp(block21)=0.;
bn(block21)=x(block21);
% else
bp(block22)=-x(block22);
bn(block22)=0.;
% end;
% end;

%
% Calcola la funz. di Bernoulli per valori
% intermedi dell'argomento
%
% if (ax > xlim),
%fprintf(1,' -> eexecuting block 3\n');
bp(block3)=x(block3)./(exp(x(block3))-1);
bn(block3)=x(block3)+bp(block3);
% else

% for ii=block4;

%
% Calcola la funz. di Bernoulli per valori
% piccoli dell'argomento mediante sviluppo
% di Taylor troncato dell'esponenziale
%
%fprintf(1,' -> eexecuting block 4\n');
if(any(block4))jj=1;
	fp=1.*ones(size(block4));
	fn=fp;
	df=fp;
	segno=1.;
	while (norm(df,inf) > eps),
		jj=jj+1;
		segno=-segno;
		df=df.*x(block4)/jj;
		fp=fp+df;
		fn=fn+segno*df;
	end;
	bp(block4)=1./fp;
	bn(block4)=1./fn;
end
% end



