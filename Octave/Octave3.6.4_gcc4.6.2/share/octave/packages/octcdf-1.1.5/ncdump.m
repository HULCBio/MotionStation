## Copyright (C) 2005 Alexander Barth
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Loadable Function} ncdump(@var{filename})
## @deftypefnx {Loadable Function} ncdump(@var{filename},@var{output_filename})
## This function writes the content of the NetCDF file @var{filename} except the actual values of the variables
## to the screen or to the file @var{output_filename} is this argument is provided. 
## The output used the same syntax that the octcdf toolbox. Therefore ncdump can be used to
## create a program that produces a NetCDF file with the same metadata than the NetCDF file
## @var{filename}.
## @end deftypefn
##
## @seealso{ncdim,ncvar,ncatt}

## Author: Alexander Barth <barth.alexander@gmail.com>



function ncdump(fname,output);

if (nargin == 1)
  fid = 1;
else
  fid = fopen(output,'w');
end

nc = netcdf(fname,'r');


fprintf(fid,'nc = netcdf(''%s'',''noclobber'');\n\n',fname);
fprintf(fid,'%% dimensions\n\n');

% query all dimensions

nd = ncdim(nc);

for i=1:length(nd)
  fprintf(fid,'nc(''%s'') = %d;\n',ncname(nd{i}),nd{i}(:));
end

fprintf(fid,'\n%% variables\n\n');

% query all variables

nv = ncvar(nc);

for i=1:length(nv)
  varname = ncname(nv{i});

  fprintf(fid,'nc{''%s''} = nc%s(',varname,ncdatatype(nv{i}));
   
  % print all dimension of the variable
  nd = ncdim(nv{i});
  n = length(nd);
  
  for j=1:n
    % dimension name in quotes    
    fprintf(fid,'''%s''',ncname(nd{j}));

    % separator
    if (j~=n)
      fprintf(fid,',');
    end    
  end
  
  fprintf(fid,');  %% %d elements \n',numel(nv{i}));

  % print all attributes of the variable
  
  na = ncatt(nv{i});

  for j=1:length(na)  
    datatype = ncdatatype(na{j});
    f = type2format(datatype);
  
    fprintf(fid,['nc{''%s''}.%s = nc%s(%s);\n'],varname,ncname(na{j}),datatype,att2str(na{j}));
  end

  fprintf(fid,'\n');  
end

fprintf(fid,'%% global attributes\n\n');

% query all global attributes

na = ncatt(nc);

for j=1:length(na)  
  datatype = ncdatatype(na{j});
  f = type2format(datatype);
  
  fprintf(fid,['nc.%s = nc%s(%s);\n'],ncname(na{j}),datatype,att2str(na{j}));
end

fprintf(fid,'close(nc)\n');

if (fid ~= 1)
  fclose(fid);
end



function f = type2format(datatype)

if (strcmp(datatype,'char'))
    f = '''%s''';
elseif (strcmp(datatype,'byte'))
    f = '%d';
else
    f = '%g';
end
  

function s = att2str(att)
 datatype = ncdatatype(att);
 f = type2format(datatype);
 
 n = length(att);
 val = att(:);
 
 if (n == 1 || strcmp(datatype,'char'))
   s = sprintf(f,val);   
 else
   s = '[';
   
   for i=1:n-1
     s = [s sprintf(f,val(i)) ' '];
   end

   s = [s  sprintf(f,val(n)) ']'];
   
 end
 

