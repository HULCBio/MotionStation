function hinfo = hdfquickinfo(filename,dataname)
%HDFQUICKINFO scan HDF file
%
%  HINFO = HDFQUICKINFO(FILENAME,DATANAME) scans the HDF file FILENAME for
%  the data set named DATANAME.  HINFO is a structure describing the data
%  set.  If no data set is found an empty structure is returned.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:10 $

found = 0;
hinfo = struct([]);

%Search for EOS data sets first because they are wrapers around HDF data
%sets

%Grid data set
if ~found
  fileID = hdfgd('open',filename,'read');
  gridID = hdfgd('attach',fileID,dataname);
  if gridID~=-1
    found = 1;
    hinfo = hdfgridinfo(filename,fileID,dataname);
    hdfgd('detach',gridID);
  end
  hdfgd('close',fileID);
end

%Swath data set
if ~found
  fileID = hdfsw('open',filename,'read');
  swathID = hdfsw('attach',fileID,dataname);
  if swathID~=-1
    found = 1;
    hinfo = hdfswathinfo(filename,fileID,dataname);
    hdfsw('detach',swathID);
  end
  hdfsw('close',fileID);
end

%Point data set
if ~found
  fileID = hdfpt('open',filename,'read');
  pointID = hdfpt('attach',fileID,dataname);
  if pointID~=-1
    found = 1;
    hinfo = hdfpointinfo(filename,fileID,dataname);
    hdfpt('detach',pointID);
  end
  hdfpt('close',fileID);
end

%Search for HDF data sets
fileID = hdfh('open',filename,'read',0);
anID = hdfan('start',fileID);

%Scientific Data Set
if ~found
  sdID = hdfsd('start',filename,'read');
  index = hdfsd('nametoindex',sdID,dataname);
  if index~=-1
    found = 1;
    hinfo = hdfsdsinfo(filename,sdID,anID,dataname);
  end
  %Close interface
  hdfsd('end',sdID);
end

%Vdata set
if ~found
  hdfv('start',fileID);
  ref = hdfvs('find',fileID,dataname);
  if ref~=0
    found = 1;
    hinfo = hdfvdatainfo(filename,fileID,anID,ref);
  end
  hdfv('end',fileID);
end
if isempty(hinfo)
  hinfo = struct([]);
end

%8-bit Raster Image
if ~found
  [name,ref] = strtok(dataname,'#');
  if strcmp('8-bit Raster Image ',name)
    %Strip off # sign
    ref = sscanf(ref(2:end), '%d');
    hinfo = hdfraster8info(filename,ref,anID);
    if ~isempty(hinfo)
      found = 1;
    end
  end
end

%24-bit Raster 
if ~found
  [name,ref] = strtok(dataname,'#');
  if strcmp('24-bit Raster Image ',name)
    %Strip off # sign
    ref = sscanf(ref(2:end), '%d');
    hinfo = hdfraster24info(filename,ref,anID);
  end
end

%Close annotation interface
hdfan('end',anID);
hdfh('close',fileID);  
return;








