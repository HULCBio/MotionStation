function Updemesh(varargin); 

% Udrawedge(mesh); 


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




if nargin == 1

	Udrawedge(varargin{1}); 

elseif nargin == 2

	mesh = varargin{1};
	u = varargin{2};

	dataname = mktemp("/tmp",".dx");
	scriptname = mktemp("/tmp",".net");

	UDXoutput2Ddata(dataname,mesh.p,mesh.t,u,'u',0,1,1);


	showmesh = file_in_path(path,"Urubbersheet.net");

	system (["cp " showmesh " " scriptname]);
	system (["sed -i \'s|__FILE__DX__|" dataname "|g\' " scriptname]);

	command = ["dx -program " scriptname " -execute -image >& /dev/null &"];
	system(command);

else

	fprintf(1,"wrong number of parameters\n\n")

end

endfunction 

function filename = mktemp (direct,ext);

if (~exist(direct,"dir"))
  error("trying to save temporary file to non existing directory")
end

done=false;

while ~done
  filename = [direct,"/SECS2D.",num2str(floor(rand*1e7)),ext];
  if ~exist(filename,"file")
    done =true;
  end
end
endfunction