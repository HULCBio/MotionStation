## Copyright (C) 2011 Johan
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## test_FixedEndForcesPnt

## Author: Johan <johan@johan-Satellite-L30>
## Created: 2011-10-02

function [ F1,F2,F3,F4,F5,F6 ] = test_FixedEndForcesPnt (l,a,Fx,Fy)
	joints=[0,0,1,1,1;
		a,0,0,0,0;
		l,0,1,1,1];
	nodeloads=[2,Fx,Fy,0];
	members=[1,2,1,1,1;
		2,3,1,1,1];
	R=SolveFrame(joints,members,nodeloads,[],[]);
	F1 = R(1,1);
	F2 = R(1,2);
	F3 = R(1,3);
	F4 = R(3,1);
	F5 = R(3,2);
	F6 = R(3,3);
endfunction
