% finfo = ncinfo(filename)
% vinfo = ncinfo(filename,varname)
% return information about complete netCDF file (filename) or about
% the specific variable varname.

function info = ncinfo(filename,varname)

nc = netcdf(filename,'r');
if nargin == 1    
    info.Filename = filename;
    
    variables = var(nc);
    for i=1:length(variables)
        info.Variables(i) = ncinfo_var(nc,filename,name(variables{i}));
    end
elseif nargin == 2
    info = ncinfo_var(nc,filename,varname);
end

close(nc);
end

function vinfo = ncinfo_var(nc,filename,varname)


nv = nc{varname};

vinfo.Size = fliplr(size(nv));
vinfo.Filename = filename;
vinfo.Dimensions = {};
vinfo.Name = varname;

dims = fliplr(dim(nv));

for i=1:length(dims)
    vinfo.Dimensions{i} = name(dims{i});
end


na = att(nv);

%vinfo.Attributes = [];

for j=1:length(na)
    tmp = struct();
    nm = name(na{j});
    
    tmp.Name = nm;
    tmp.Value = na{j}(:);
    vinfo.Attributes(j) = tmp;
end

vinfo.FillValue = fillval(nv);


end

