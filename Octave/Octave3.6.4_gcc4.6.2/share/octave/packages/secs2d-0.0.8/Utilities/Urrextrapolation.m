function s = Urrextrapolation(X)
  
%  s = Urrextrapolation(X)
%  RRE vector extrapolation see 
%  Smith, Ford & Sidi SIREV 29 II 06/1987
  
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

  if (Ucolumns(X)>Urows(X))
    X=X';
  end
  
  % compute first and second variations
  U = X(:,2:end) - X(:,1:end-1);
  V = U(:,2:end) - U(:,1:end-1);
  
  % eliminate unused u_k column
  U(:,end) = [];
  
  s = X(:,1) - U * pinv(V) * U(:,1);
  
