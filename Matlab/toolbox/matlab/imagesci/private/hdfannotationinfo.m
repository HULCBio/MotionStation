function [label, desc] = hdfannotationinfo(anID,tag,ref)
%HDFANNOTATIONINFO Retrieve about HDF Annotation. 
%
%   [LABEL, DESC] = HDFANNOTATIONINFO(ANID,TAG,REF) returns the data
%   description DESC, and data label LABEL, for the HDF object described by
%   the TAG, REF pair in the annotation specified by ANID.  ANID is the AN
%   identifier returned by hdfan('start',...).  If no label or description
%   exist for the HDF object, then LABEL and DESC will be empty cell arrays.
%
%   Assumptions: 
%               1.  The file has been open.
%               2.  The AN interface has been started.
%               3.  The AN interface and file will be closed elsewhere.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:05 $

label = {};
desc = {};

% hdfan('annlen',...) does not include null termination character read by 
% hdfan('readann'...). Adding 1 to length for this reason.
numDataLabel = hdfan('numann',anID,'data_label',tag,ref);
hdfwarn(numDataLabel)
if numDataLabel>0
  [DataLabelID,status] = hdfan('annlist',anID,'data_label',tag,ref);
  hdfwarn(status)
  if status~=-1
    for i=1:numDataLabel
      length = hdfan('annlen',DataLabelID(i));
      hdfwarn(length)
      [label{i},status] = hdfan('readann',DataLabelID(i),length+1);
      hdfwarn(status)
    end
  end
end
numDataDesc = hdfan('numann',anID,'data_desc',hdfml('tagnum','DFTAG_NDG'),ref);
hdfwarn(numDataDesc)
if numDataDesc >0
  [DataDescID, status] = hdfan('annlist',anID,'data_desc',hdfml('tagnum','DFTAG_NDG'),ref);
  if status~=-1
    for i=1:numDataDesc
      length = hdfan('annlen',DataDescID(i));
      hdfwarn(length)
      desc{i} = hdfan('readann',DataDescID(i),length+1);
      hdfwarn(status)
    end
  end
end
return;
