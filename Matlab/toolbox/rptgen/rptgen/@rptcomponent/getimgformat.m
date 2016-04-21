function fInfo=getimgformat(c,ID)
%GETIMGFORMAT  Returns extension and device information
%   a=GETIMGFORMAT(rptcomponent,ID) returns a structure
%   which describes the image format designated by ID.
%   
%   For a structure containing all valid formats, use ID='ALL';
%   For a structure containing all valid formats for Figures,
%    Simulink, or Stateflow, use ID='ALLHG','ALLSL', or 'ALLSF'
%    respectively.
%   For a structure containing the default image format for
%    Figures, Simulink, or Stateflow, use ID='AUTOHG','AUTOSL', or
%    'AUTOSF' respectively.  These AUTOXX images are set
%    in RPTPARENT/PREFERENCES.
%
%   Fields in each structure are:
%     .ID - a unique identifier to the format
%     .name - a description of the format
%     .ext - the file extension to be used with the format
%     .driver - print driver (such as -dps or -dtiff)
%     .options - a cell array of print options
%     .isSL - 1 if can be used with Simulink, 0 if not
%     .isSF - 1 if can be used with Stateflow, 0 if not
%     .isHG - 1 if can be used with Handle Graphics, 0 if not
%
%   See also RPTPARENT/PREFERENCES

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:02 $

allFormats=allFormatsList;
switch ID
case 'ALL'
   idx=[1:size(allFormats,1)];
case 'ALLSL'
   idx=find([allFormats{:,6}]);
case 'ALLSF'
   idx=find([allFormats{:,7}]);
case 'ALLHG'
   idx=find([allFormats{:,8}]);
case 'AUTOSL'
   ID=LocGetAutoID(c,'ImageSL');
   idx=find(strcmp(allFormats(:,1),ID));
case 'AUTOSF'
   ID=LocGetAutoID(c,'ImageSF');
   idx=find(strcmp(allFormats(:,1),ID));
case 'AUTOHG'
   ID=LocGetAutoID(c,'ImageHG');
   idx=find(strcmp(allFormats(:,1),ID));
otherwise
   idx=find(strcmp(allFormats(:,1),ID));
end

fInfo=struct('ID',allFormats(idx,1),...
   'name',allFormats(idx,2),...
   'ext',allFormats(idx,3),...
   'driver',allFormats(idx,4),...
   'options',allFormats(idx,5),...
   'isSL',allFormats(idx,6),...
   'isSF',allFormats(idx,7),...
   'isHG',allFormats(idx,8));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allFormats=allFormatsList

isPC=strcmp(computer,'PCWIN');

%1=unique identifier
%2=name
%3=file extension
%4=device
%5=options
%6=is ok for simulink
%7=is ok for stateflow
%8=is ok for HG

rezString=sprintf('-r%i',round(get(0,'screenpixelsperinch')));

allFormats={'ps','Black and white PostScript',...
      'ps','-dps',{},1,1,1;
   'psc','Color PostScript',...
      'ps','-dpsc',{},1,1,1;
   'ps2','Black and white PostScript2',...
      'ps','-dps2',{},1,1,1;
   'psc2','Color PostScript2',...
      'ps','-dpsc2',{},1,1,1;
   'eps','Black and white encapsulated PostScript',...
      'eps','-deps',{},1,1,1;
   'epsc','Color encapsulated PostScript',...
      'eps','-depsc',{},1,1,1;
   'eps2','Black and white encapsulated PostScript2',...
      'eps','-deps2',{},1,1,1;
   'epsc2','Color encapsulated PostScript2',...
      'eps','-depsc2',{},1,1,1;
   'epst','Black and white encapsulated PostScript (TIFF preview)',...
      'eps','-deps',{'-tiff'},1,1,1;
   'epsct','Color encapsulated PostScript (TIFF preview)',...
      'eps','-depsc',{'-tiff'},1,1,1;
   'eps2t','Black and white encapsulated PostScript2 (TIFF preview)',...
      'eps','-deps2',{'-tiff'},1,1,1;
   'epsc2t','Color encapsulated PostScript2 (TIFF preview)',...
      'eps','-depsc2',{'-tiff'},1,1,1;
   'ill','Adobe Illustrator',...
      'ill','-dill',{},0,1,1;
   'bmp256','256-color bitmap',...
      'bmp','-dbmp256',{rezString},1,1,1;
   'bmp16m','16m-color bitmap',...
      'bmp','-dbmp16m',{rezString},1,1,1;
   'jpeg90','JPEG high quality image',...
      'jpg','-djpeg90',{rezString},1,1,1;
   'jpeg75','JPEG medium quality image',...
      'jpg','-djpeg75',{rezString},1,1,1;
   'jpeg30','JPEG low quality image',...
      'jpg','-djpeg30',{rezString},1,1,1;
   'png','PNG - Portable Network Graphics 24-bit image',...
      'png','-dpng',{rezString},1,1,1;
   'tiffc','TIFF - compressed',...
      'tiff','-dtiff',{rezString},0,1,1;
   'tiffu','TIFF - uncompressed',...
      'tiff','-dtiffnocompression',{rezString},0,1,1;
   'wmf','Windows metafile',...
      'emf','-dmeta',{},isPC,isPC,isPC;
   'AUTOHG','Automatic Handle Graphics Format',...
      '','',{},0,0,1;
   'AUTOSL','Automatic Simulink Format',...
      '','',{},1,0,0;
   'AUTOSF','Automatic Stateflow Format',...
      '','',{},0,1,0};

if ispc
    pcFormats={
        'png-capture','PNG (screenshot)',...
            'png','-dbitmap',{},1,0,0;
        'bmp-capture','Bitmap (screenshot)',...
            'bmp','-dbitmap',{},0,0,0;};
    allFormats=[allFormats;pcFormats];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autoID=LocGetAutoID(c,autoType)

targetFormat=subsref(rptcomponent,...
   substruct('.','Format'));
allPrefs=preferences(c);
allPrefs=allPrefs.format;
formatIndex=find(strcmpi({allPrefs.Name},targetFormat));
if isempty(formatIndex)
   formatIndex=1;
else
   formatIndex=formatIndex(1);
end

autoID=getfield(allPrefs(formatIndex),autoType);