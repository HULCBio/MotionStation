function B=subsref(A,S)
%SUBSREF Subscripted reference
%   B=SUBSREF(RPTCOMPONENT,S) gets information from a persistent
%   structure, not the RPTCOMPONENT object (which is actually empty).
%   The structure is stored in RPTCOMPONENT/RGSTOREDATA.  If a
%   field is requested which has not been initialized yet, SUBSREF
%   will make a best guess.
%
%   See also SUBSASGN, RGSTOREDATA

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:21 $

d=rgstoredata(A);

if ~isstruct(d)
   d=initialize(A);
end

if strcmp(S(1).subs,'comps')
   if ~isfield(d,'comps')
      d.comps=[];
   end
   
   if length(S)>1
      d.comps=VerifyFieldComps(d.comps,S(2).subs);
   end   
else
   d=VerifyField(d,S(1).subs);
end

B=builtin('subsref',d,S);

rgstoredata(A,d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d=VerifyField(d,whichField);

if ~isfield(d,whichField) | ... 
   isempty(builtin('subsref',d,substruct('.',whichField)))
   switch whichField
   case 'ReportDirectory'
      d.ReportDirectory=pwd;
   case 'ReportFilename'
      d.ReportFilename='Unnamed';
   case 'ReportExt'
      d.ReportExt='html';
   case 'Format'
      d.Format='html';
   case 'ImageDirectory'
      %if ImageDirectory is empty, it means it has not been
      %requested yet.  We may have to create the directory
      %or delete the report's existing images
      d=VerifyField(d,'ReportDirectory');
	  d=VerifyField(d,'ReportFilename');
      d=VerifyField(d,'ReportExt');

      %create report images directory
      dirName=[d.ReportFilename '_' d.ReportExt '_' 'files'];
      
      mkdirOK=mkdir(d.ReportDirectory,dirName);
      if mkdirOK==1      %directory created successfully
         d.ImageDirectory=fullfile(d.ReportDirectory,dirName);
      elseif mkdirOK==2  %directory already exists
         d.ImageDirectory=fullfile(d.ReportDirectory,dirName);
         % Note that deletion of existing files
         % (when isRegenerateImages is true)
         % takes place in coutline/execute
      else  %directory not successfully created
         warning('Could not create Report Images directory.');
         d.ImageDirectory=d.ReportDirectory;
      end
      
   case 'ImagePreface'
       
      d=VerifyField(d,'ImageDirectory');
      d.ImagePreface=fullfile(d.ImageDirectory,...
         'image');
      
   %ScanDocumentForImports - logical(0)
   otherwise
      freshD=initialize(rptcomponent);
      thisSubs=substruct('.',whichField);
      d=setfield(d,whichField,getfield(freshD,whichField));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rgdc=VerifyFieldComps(rgdc,cName);

if ~isfield(rgdc,cName) | ~ishandle(getfield(rgdc,cName))
   try
      rgdc=setfield(rgdc,cName,eval(cName));
   catch
      error('Invalid component name requested');      
   end
else
   %the component already exists.  We must
   %getinfo it and reset its fields to defaults.
   p=getfield(rgdc,cName);
   c=get(p,'UserData');
   i=getinfo(c);
   c=subsasgn(c,substruct('.','att'),i.att);
   c=subsasgn(c,substruct('.','x'),i.x);
   c=subsasgn(c,substruct('.','ref'),i.ref);
   set(p,'UserData',c);
end