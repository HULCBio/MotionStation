function dataRef=getcdata(r,dataRef,bgc)
%GETCDATA returns background-transparent button CDATA
%   CDATA=GETCDATA(R,FILENAME,BGC)
%      R is an RPTCOMPONENT object
%      FILENAME is the full path to a MAT-file containing CDATA images
%         if FILENAME is empty or omitted,
%         use MATLABROOT/toolbox/rptgen/rptgenv1/resources/rptcdata.mat
%      BGC (optional) - backgroundcolor to use.  Should be a 1x3 colorspec 
%         default is get(0,'defaultuicontrolbackgroundcolor')
%
%   CDATA=GETCDATA(R,FSTRUCT,BGC)
%      R is an RPTCOMPONENT object
%      FSTRUCT is a structure containing CDATA

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:01 $

if nargin<3
   bgc=255*get(0,'DefaultUIcontrolBackgroundColor');
   if nargin<2
      dataRef='';
   end
else
   bgc=255*bgc;
end

if ischar(dataRef)
   if isempty(dataRef)
	   dataRef=[matlabroot filesep 'toolbox' filesep ...
		   'rptgen' filesep 'rptgenv1' filesep 'resources' filesep ...
		   'rptbuttoncdata.mat'];
   end
   
   try
      dataRef=load(dataRef,'-mat');
   catch
      warning(sprintf('CDATA MAT-file %s could not be loaded.', dataRef));
      dataRef=[];
   end
end

if isstruct(dataRef)
   dataRef=LocProcessStructure(dataRef,bgc);
else
   dataRef=[];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   cdStruct=LocProcessStructure(cdStruct,bgc);

sFieldnames=fieldnames(cdStruct);

for i=1:length(sFieldnames)
   sField=getfield(cdStruct,sFieldnames{i});
   if isstruct(sField)
      sField=LocProcessStructure(sField,bgc);
   elseif isnumeric(sField)
      sField=LocProcessMatrix(sField,bgc);
   end   
   cdStruct=setfield(cdStruct,sFieldnames{i},sField);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cData=LocProcessMatrix(cData,bgc);
%remove NAN's out and replace with BGC

nanIndex=find(isnan(cData(:,:,1)));
if ~isempty(nanIndex)
   for k=1:3
      cLayer=cData(:,:,k);
      cLayer(nanIndex)=ones(1,length(nanIndex))*bgc(k);
      cData(:,:,k)=cLayer;
   end
end

cData=uint8(cData);