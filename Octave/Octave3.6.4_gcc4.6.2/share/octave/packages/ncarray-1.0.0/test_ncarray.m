% Test ncBaseArray, ncCatArray and ncArray.
function test_ncarray()

varname = 'SST';

tmpdir = tempname;
mkdir(tmpdir);

tmpfname = tempname(tmpdir);
for i = 1:3  
  files{i} = fullfile(tmpdir,sprintf('file%d.nc',i));
  ncarray_example_file(files{i},randn(220,144));
end


filename = files{1};


% test ncread/ncwrite

copyfile(files{1},tmpfname);
SST_ref = ncread(files{1},'SST');
ncwrite(tmpfname,'SST',zeros(size(SST_ref)));
test = ncread(tmpfname,'SST');

assert(all(test(:) == 0))

ncwrite(tmpfname,'SST',SST_ref);
test = ncread(tmpfname,'SST');
assert(isequalwithequalnans(test,SST_ref))


%%% test ncBaseArray

% reading

copyfile(files{2},tmpfname);
SST = ncBaseArray(tmpfname,varname);
test = SST(:,:,:);
SST_ref = ncread(tmpfname,varname);

assert(isequalwithequalnans(test,SST_ref))
assert(isempty(SST(:,:,:,[])));
assert(isequalwithequalnans(SST_ref, SST(:,:,:,1)))

ind = floor(numel(SST_ref) * rand(100,1))+1;
assert(isequalwithequalnans(SST(ind),SST_ref(ind)))

% writing

r = round(randn(size(SST)));
SST(:,:,:) = r;
SST_ref = ncread(tmpfname,varname);
assert(isequalwithequalnans(r,SST_ref));

SST(:,:,:) = 3 * r;
SST_ref = ncread(tmpfname,varname);
assert(isequalwithequalnans(3 * r,SST_ref));



%%% test ncArray

% reading

copyfile(files{2},tmpfname);
SST = ncArray(tmpfname,varname);
test = SST(:,:,:);
SST_ref = ncread(tmpfname,varname);

assert(isequalwithequalnans(test,SST_ref))
assert(isempty(SST(:,:,:,[])));
assert(isequalwithequalnans(SST_ref, SST(:,:,:,1)))

ind = floor(numel(SST_ref) * rand(100,1))+1;
assert(isequalwithequalnans(SST(ind),SST_ref(ind)))

assert(isequalwithequalnans(SST_ref(1,:,:), SST(1,:,:)))

% sum


%momentSST = moment(SST,2,1);
%momentSSTref = moment(SST_ref,2,1);
%assert(isequalwithequalnans(momentSST, momentSSTref))


sumSST = sum(SST,1);
sumSSTref = sum(SST_ref,1);
assert(isequalwithequalnans(sumSST, sumSSTref))

sumSST = sum(SST,2);
sumSSTref = sum(SST_ref,2);
assert(isequalwithequalnans(sumSST, sumSSTref))

sumSST = sum(SST,3);
sumSSTref = sum(SST_ref,3);
assert(isequalwithequalnans(sumSST, sumSSTref))

sumSST = sum(SST);
sumSSTref = sum(SST_ref);
assert(isequalwithequalnans(sumSST, sumSSTref))

prodSST = prod(SST);
prodSSTref = prod(SST_ref);
assert(isequalwithequalnans(prodSST, prodSSTref))

% only for octave
%sumsqSST = sumsq(SST);
%sumsqSSTref = sumsq(SST_ref); % does not work in matlab
%assert(isequalwithequalnans(sumsqSST, sumsqSSTref))

meanSST = mean(SST);
meanSSTref = mean(SST_ref);
assert(isequalwithequalnans(meanSST, meanSSTref))

varSST = var(SST);
varSSTref = var(SST_ref);
assert(isequalwithequalnans(varSST, varSSTref))

varSST = var(SST,1);
varSSTref = var(SST_ref,1);
assert(isequalwithequalnans(varSST, varSSTref))

varSST = var(SST,[],2);
varSSTref = var(SST_ref,[],2);
assert(isequalwithequalnans(varSST, varSSTref))

stdSST = std(SST);
stdSSTref = std(SST_ref);
assert(isequalwithequalnans(stdSST, stdSSTref))

stdSST = std(SST,1);
stdSSTref = std(SST_ref,1);
assert(isequalwithequalnans(stdSST, stdSSTref))

stdSST = std(SST,[],2);
stdSSTref = std(SST_ref,[],2);
assert(isequalwithequalnans(stdSST, stdSSTref))

maxSST = max(SST,[],2);
maxSSTref = max(SST_ref,[],2);
assert(isequalwithequalnans(maxSST, maxSSTref))

minSST = min(SST,[],2);
minSSTref = min(SST_ref,[],2);
assert(isequalwithequalnans(minSST, minSSTref))


% writing

r = round(randn(size(SST)));
SST(:,:,:) = r;
SST_ref = ncread(tmpfname,varname);
assert(isequalwithequalnans(r,SST_ref));

SST(:,:,:) = 3 * r;
SST_ref = ncread(tmpfname,varname);
assert(isequalwithequalnans(3 * r,SST_ref));



%%% CatArray

% reading

CA = CatArray(3,{...
    ncArray(filename,varname),...
    ncArray(files{2},varname),...
    ncArray(files{3},varname)...
    });

assert(isequalwithequalnans(size(CA),[220   144     3]))

SST_ref = ncread(filename,'SST');
tmp2 = CA(:,:,1);
assert(isequalwithequalnans(SST_ref,tmp2))



SST_test = CA(:,:,2);
SST_ref = ncread(files{2},'SST');



assert(isequalwithequalnans(SST_test,SST_ref))

CA2 = CatArray(4,{...
    ncArray(files{1},varname),...
    ncArray(files{2},varname),...
    ncArray(files{3},varname)...
    });

SST_test = CA2(:,:,:,2);

assert(isequalwithequalnans(SST_test,SST_ref))

CA2 = ncCatArray(3,{...
    files{1},...
    files{2},...
    files{3}},...
    varname);

SST_test = CA2(:,:,2);
assert(isequalwithequalnans(SST_test,SST_ref))

CA2 = ncCatArray(3,fullfile(tmpdir,'file*nc'),varname);
SST_test = CA2(:,:,2);
assert(isequalwithequalnans(SST_test,SST_ref))


CA2 = ncCatArray(3,...
    @(i) fullfile(tmpdir,sprintf('file%d.nc',i)),...
    varname,...
    1:3);

SST_test = CA2(:,:,2);
assert(isequalwithequalnans(SST_test,SST_ref))

SST_ref = cat(3,...
    ncread(files{1},'SST'),...
    ncread(files{2},'SST'),...
    ncread(files{3},'SST'));


assert(isequalwithequalnans(CA2(:,:,:),SST_ref))

assert(isequalwithequalnans(CA2(:,:,1),SST_ref(:,:,1)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:100,1),SST_ref(3:5:50,3:5:100,1)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:100,2),SST_ref(3:5:50,3:5:100,2)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:100,3),SST_ref(3:5:50,3:5:100,3)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:100,end),SST_ref(3:5:50,3:5:100,end)))
assert(isequalwithequalnans(CA2(50,100,1:3),SST_ref(50,100,1:3)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:100,1:2:3),SST_ref(3:5:50,3:5:100,1:2:3)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:end,1:2:3),SST_ref(3:5:50,3:5:end,1:2:3)))
assert(isequalwithequalnans(CA2(3:5:50,3:5:end,:),SST_ref(3:5:50,3:5:end,:)))
ind = floor(numel(SST_ref) * rand(100,1))+1;
assert(isequalwithequalnans(CA2(ind),SST_ref(ind)))

meanSST = mean(CA2,3);
meanSSTref = mean(SST_ref,3);
assert(isequalwithequalnans(meanSST, meanSSTref))

% writing

for i=1:3
    list{i} = tempname;
    copyfile(filename,list{i});
end

CA2 = ncCatArray(3,list,varname);
r = round(randn(size(CA2)));
CA2(:,:,:) = r;

check = ncread(list{2},varname);
assert(isequalwithequalnans(check,r(:,:,2)))

r2 = round(randn(size(CA2)));
r(3:5:50,3:5:end,:) = r2(3:5:50,3:5:end,:);
CA2(3:5:50,3:5:end,:) = r2(3:5:50,3:5:end,:);
assert(isequalwithequalnans(CA2(:,:,:),r))

r(end-1,3:5:end,1:2:3) = 2*r2(end-1,3:5:end,1:2:3);
CA2(end-1,3:5:end,1:2:3) = 2*r2(end-1,3:5:end,1:2:3);
assert(isequalwithequalnans(CA2(:,:,:),r))




if 1
    % test ncArray (constructor: ncArray(var,dims,coord)
    
    SST = ncBaseArray(filename,varname);
    SST_ref = ncread(filename,varname);
    lon_ref = ncread(filename,'lon');
    
    coord(1).val = ncBaseArray(filename,'lon');
    coord(1).dims = {'x','y'};
    
    coord(2).val = ncBaseArray(filename,'lat');
    coord(2).dims = {'x','y'};
    
    coord(3).val = ncBaseArray(filename,'time');
    coord(3).dims = {'time'};
    
    data = ncArray(SST,{'x','y','time'},coord);
    
    [x,y,t] = data(:,:,:).coord;
    
    assert(isequalwithequalnans(data(:,:,:),SST_ref))
    assert(isequalwithequalnans(x,lon_ref))
    
    assert(isequalwithequalnans(data(),SST_ref))
    [x,y,t] = data().coord;
    assert(isequalwithequalnans(x,lon_ref))
    
    assert(isequalwithequalnans(data(1:3:end,:,:),SST_ref(1:3:end,:,:)))
    [x,y,t] = data(1:3:end,:,:).coord;
    assert(isequalwithequalnans(x,lon_ref(1:3:end,:)))
    
    % test ncArray (constructor: ncData(filename,varname)
    SST = ncArray(filename,varname);
    [x,y,t] = data(:,:,:).coord;
    
    assert(isequalwithequalnans(data(:,:,:),SST_ref))
    assert(isequalwithequalnans(x,lon_ref))
    
    assert(isequalwithequalnans(data(),SST_ref))
    [x,y,t] = data().coord;
    assert(isequalwithequalnans(x,lon_ref))
    
    assert(isequalwithequalnans(data(1:3:end,:,:),SST_ref(1:3:end,:,:)))
    [x,y,t] = data(1:3:end,:,:).coord;
    assert(isequalwithequalnans(x,lon_ref(1:3:end,:)))
    
    
    assert(strcmp(SST.units,'degC'))
    assert(strcmp(SST.('units'),'degC'))
    
end


% read compressed data
zname = [tmpfname '.gz'];
system(['gzip --stdout ' tmpfname ' > ' zname]);

SST = ncArray(zname,'SST');
SST_ref = ncread(tmpfname,'SST');
assert(isequalwithequalnans(SST(),SST_ref))



CA2 = ncCatArray(3,fullfile(tmpdir,'file*nc'),varname);
SST_test = CA2(:,:,2);
SST_ref = ncread(files{2},'SST');
assert(isequalwithequalnans(SST_test,SST_ref))

assert(strcmp(CA2.units,'degC'));

disp('All tests passed.')



% Copyright (C) 2012 Alexander Barth <barth.alexander@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.

