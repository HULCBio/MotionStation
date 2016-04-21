function UDXappend2Ddata(filename,p,t,u,attr_name,attr_rank,attr_shape,endfile)

%
%   UDXappend2Ddata(filename,p,t,u,attr_name,attr_rank,attr_shape)
%
%   Apends data to a file in DX form.
%   Only one variable can be written to the file
%   variable must be a scalar, vector or tensor of doubles   
%   mesh data in the file must be consistent with this variable
%
%   x
%   attr_name  = name of the variable                   (type string)
%   attr_rank  = rank of variable data                  (0 for scalar, 1 for vector, etc.)
%   attr_shape = number of components of variable data  (assumed 1 for scalar)
%

p = p';
t = t';
t = t(:,1:3);

%eval(['!rm -f ',filename]);

fid=fopen (filename,'a');
Nnodi = size(p,1);
Ntriangoli = size(t,1);

fprintf(fid,'\nattribute "element type" string "triangles"\nattribute "ref" string "positions"\n\n');

if ((attr_rank==0) & (min(size(u))==1))
    fprintf(fid,'object "%s.data"\nclass array type double rank 0 items %d data follows',attr_name,Nnodi);
    fprintf(fid,'\n %1.7e',u);
else
    fprintf(fid,'object "%s.data"\nclass array type double rank %d shape %d items %d data follows', ...
        attr_name,attr_rank,attr_shape,Nnodi);
    for i=1:Nnodi
        fprintf(fid,'\n');
        fprintf(fid,'    %1.7e',u(i,:));
    end
end
fprintf(fid,['\nattribute "dep" string "positions"\n\n' ...
             'object "%s" class field\n'...
             'component "positions" value "pos"\n'...
             'component "connections" value "con"\n'...
             'component "data" value "%s.data"\n'],...
              attr_name,attr_name);

if(endfile)
    fprintf(fid,'\nend\n');
end

fclose (fid);


% Last Revision:
% $Author: cdf $
% $Date: 2007-05-22 21:16:23 +0200 (tir, 22 maj 2007) $
