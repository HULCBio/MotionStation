function [out1,out2]=getimgname(c,varargin)
%GETIMGNAME returns a filename for use as a Report Generator image
%   Returns an appropriate filename for the image.  The filename
%   is of the form ReportDirectory/rName_rExt_files/image-###-DESC.ext
%   where ### is a unique number.
%
%   NAME=GETIMGNAME(C,IMGINFO,DESC)
%   * C is any report generator component
%   * IMGINFO is a structure of the type returned by GETIMGFORMAT
%   * DESC (optional) is a string appended to the filename for
%     identification purposes.  If DESC is not specified, 'etc' is used
%   * NAME is the name to which the image file should be saved.  
%
%
%   [NAME,ISNEW]=GETIMGNAME(C,IMGINFO,DESC,SOURCEID)
%   * SOURCEID is a non-session-dependent identifier for the image.
%       (Such as a full path name in Simulink or Stateflow).
%   * ISNEW returns logical(0) if an image file already exists which
%        corresponds to this sourceID, meaning that the calling
%        component may not have to re-generate it and can just use
%        the given filename.  If an image does not exist for the specified
%        SOURCEID, ISNEW returns logical(1).
%
%   [IMDB,ISOK]=GETIMGNAME(C,'$SaveVariables') will save the image database
%   out to ReportDirectory/rName_rExt_files/image-list.mat
%   * IMDB = the image database structure
%   * ISOK = returns whether the structure was successfully saved
%
%   [FNAMES,ISOK]=GETIMGNAME(C,'$ListFiles') will open the image database
%   and return all the filenames including the name of the database file
%   * FNAMES = the file list
%   * ISOK = returns whether the structure was successfully loaded
%
%   See also GETIMGFORMAT

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:03 $

if ischar(varargin{1})
   switch varargin{1}
   case '$SaveVariables'
      [out1,out2]=LocSaveVariables;
   case '$ReorderFiles'
      [out1,out2]=LocListFiles;
   case '$ListFiles'
      [out1,out2]=LocListFiles;
   otherwise
      error(sprintf('"%s" not a valid command',varargin{1}));
   end
else
   [out1,out2]=LocImageName(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imageDescriptions,isOK]=LocSaveVariables

r=rptcomponent;

%we want to see if ImagePreface has been defined yet.
%If it has, it means that images may have been generated
rgd=rgstoredata(r);

if isfield(rgd,'ImagePreface') & ~isempty(rgd.ImagePreface)
   imageDescriptions=NewImageList;
   try
      save(LocDatabaseFileName(rgd.ImagePreface),...
         'imageDescriptions');
      isOK=logical(1);
   catch
      isOK=logical(0);
   end
else
   imageDescriptions=[];
   isOK=logical(0);
end

%We clear out the persistent data structures here in order
%to prevent their accidental use on the next report generated
LocImageNumber([]);
NewImageList([]);
OldImageList([]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fList,isOK]=LocListFiles

oList=OldImageList;
if length(oList)>0
   LocImageNumber(max([oList.idx]));
   fList={LocDatabaseFileName, oList(:).fileName}';
   isOK=1;
else
   LocImageNumber(0);
   fList={};
   isOK=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imgName,isNew]=LocImageName(imgInfo,...
   descString,...
   sourceID)

filePrefix=subsref(rptcomponent,substruct('.','ImagePreface'));
if nargin<3
   isRecord=0;
   if nargin<2
      descString='etc';
   end
else      
   oList=OldImageList;
   if length(oList)>0
      sourceIndex=find(strcmp({oList.sourceID},sourceID));
      %first we need to find something with a matching name
      if ~isempty(sourceIndex)
         %then we need to find something with a matching img type
         imgIndex=find(strcmp({oList(sourceIndex).imgID},imgInfo.ID));
         if ~isempty(imgIndex)
            sourceIndex=sourceIndex(imgIndex(1));
         else
            sourceIndex=[];
         end
      end
   else
      sourceIndex=[];
   end
   
   if length(sourceIndex)>0
      %disp('Using existing image file!')
      isRecord=sourceIndex(1);
   else
      isRecord=-1;
   end
end

%isRecord>0 = getting filename from record index isRecord
%isRecord=0 = new name, don't save ID
%isRecord<0 = new name, save ID

if isRecord>0
   imgName=oList(isRecord).fileName;
   isNew=logical(0);
else
   
   imgNum=LocImageNumber;
   imgName=sprintf('%s-%i-%s.%s',...
      filePrefix,...
      imgNum,...
      descString,...
      imgInfo.ext);
   isNew=logical(1);
   
   if isRecord<0        
      %add the file sourceID to the list of files
      NewImageList(struct('sourceID',sourceID,...
         'imgID',imgInfo.ID,...
         'fileName',imgName,...
         'idx',imgNum));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iNum=LocImageNumber(iNum)
%LocImageNumber([]) clears out the persistent variable

persistent RPTGEN_IMAGE_NUMBER
mlock;

if nargin==1
   RPTGEN_IMAGE_NUMBER=iNum;
elseif isempty(RPTGEN_IMAGE_NUMBER)
   RPTGEN_IMAGE_NUMBER=0;
else
   RPTGEN_IMAGE_NUMBER=RPTGEN_IMAGE_NUMBER+1;
end

iNum=RPTGEN_IMAGE_NUMBER;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nList=NewImageList(listEntry)
%NewImageList([]) clears out the persistent variable

persistent RPTGEN_NEW_IMAGE_LIST
mlock;

if ~isstruct(RPTGEN_NEW_IMAGE_LIST)
   RPTGEN_NEW_IMAGE_LIST=OldImageList;
   %disp('retrieving old list');
end

if nargin>0
    if isempty(listEntry)
        RPTGEN_NEW_IMAGE_LIST=listEntry;
    else
        
        RPTGEN_NEW_IMAGE_LIST(end+1)=listEntry;
    end
end

nList=RPTGEN_NEW_IMAGE_LIST;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oList=OldImageList(filePrefix)
%OldImageList([]) clears out the persistent variable

persistent RPTGEN_IMAGE_LIST
mlock;

if nargin>0 & isempty(filePrefix)
    RPTGEN_IMAGE_LIST = filePrefix;
elseif ~isstruct(RPTGEN_IMAGE_LIST)
   if nargin<1
      filePrefix=subsref(rptcomponent,...
         substruct('.','ImagePreface'));
   end
   
   dbFile = LocDatabaseFileName(filePrefix);
   if exist(dbFile,'file')>0
       try
           load(dbFile,'-mat');
       end
   end
   
   if exist('imageDescriptions','var')>0
      RPTGEN_IMAGE_LIST=imageDescriptions;
   else
      RPTGEN_IMAGE_LIST=struct('sourceID',{},...
         'imgID',{},...
         'fileName',{},...
         'idx',{});
   end
end

oList=RPTGEN_IMAGE_LIST;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fName=LocDatabaseFileName(prefaceName)

if nargin<1
   r=rptcomponent;
   prefaceName=subsref(rptcomponent,...
      substruct('.','ImagePreface'));
end

fName=[prefaceName '-filelist.mat'];
