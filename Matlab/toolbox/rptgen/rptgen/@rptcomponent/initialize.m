function varargout=initialize(r,coutlineHandle)
%INITIALIZE sets up the static data strucutre for reporting
%  INITIALIZE(RPTCOMPONENT)
%  
%  SEE ALSO: CLEANUP
%
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:07 $

if nargin<2
   pathName=[pwd filesep];
else
   try
      parentHandle=get(coutlineHandle,'Parent');
      setfile=get(parentHandle,'UserData');
      pathName=setfile.ref.Path;
   catch
      pathName=[pwd filesep];
   end
end

langString=get(0,'Language');
if length(langString)>=2
   langString=lower(langString(1:2));
   switch langString
   case 'en'
      langCode='';
   %case 'us'
   %   langCode='usen'; %specifically call US english localization
   case {'ge' 'de'}
      langCode='dege';
   case {'ja'}
      langCode='ja';
   %case {'sp' 'es'}
   %   langCode='es';
   %case {'ru'}
   %   langCode='ru'; %buggy
   %case 'dk'
   %   langCode='dk'; %buggy
   %case 'fr'
   %   langCode='fr';
   %case 'it'
   %   langCode='it'; %not localized in db1.20
   %case 'nl'
   %   langCode='nl'; %not localized in db1.20 
   %case 'pl'
   %   langCode='pl';
   %case 'pt'
   %   langCode='pt';
   otherwise
      langCode='';
   end
else
   langCode='';
end
%langCode='dege';

if ~isempty(what('rptsp'))
	clipboardPointer=rptsp('clipboard');
	preRunClipboard = allchild(clipboardPointer.h);
else
	preRunClipboard = [];
end

d=struct('ReportDirectory','',...
   'ReportFilename','',...
   'ReportExt','',...
   'Format','',...
   'Language',langCode,...
   'ImageDirectory','',...
   'ImagePreface','',...
   'SetfilePath',pathName,...
   'HaltGenerate',logical(0),...
   'stack',rptcp,...
   'DebugMode',logical(0),...
   'DocBookCalloutCounter',0,...
   'DocBookDoctype','Sect1',...
   'DocBookSectionCounter',[0],...
   'comps',[],...
   'ScanDocumentForImports',logical(0),...
   'PreRunClipboardHandles',preRunClipboard);

%status.m contains a persistent variable which stores the
%handle of the generation status listbox.  It must be cleared
%from generation to generation in case the listbox has been
%created or closed since the last generate action.
if mislocked('rptcomponent/status')
    try
        munlock('rptcomponent/status');
        clear('rptcomponent/status');
    end
end


if nargout==1
   varargout{1}=d;
else
   rgstoredata(r,d);
end
