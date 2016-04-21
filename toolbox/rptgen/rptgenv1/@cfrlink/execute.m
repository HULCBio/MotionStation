function out=execute(c)
%EXECUTE report output
%   OUTSTRING=EXECUTE(CFRLINK)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:27 $


linkText= parsevartext(c.rptcomponent,c.att.LinkText);
linkID  = parsevartext(c.rptcomponent,c.att.LinkID);

switch lower(c.att.LinkType)
case 'link' 
   idName='Linkend';
   endTag=logical(1);
   lType='Link';
   if isempty(linkText)
       linkText=linkID;
   end
case 'ulink'
   idName='URL';
   endTag=logical(1);
   lType='Ulink';
   if isempty(linkText)
       linkText=linkID;
   end
   if isempty(findstr(linkID,':/')) & ...
           isempty(findstr(linkID,'./'))
       if exist(linkID,'file')>0
           [linkPath,linkFile,linkExt]=fileparts(which(linkID));
           if strcmpi(linkPath,c.rptcomponent.ReportDirectory)
               linkID=['./',linkFile,linkExt];
           else
               linkID = ['file:///',fullfile(linkPath,[linkFile,linkExt])];
           end
       else
           linkID = ['http://',linkID];
       end
   end
case 'anchor'
   idName='ID';
   endTag=logical(0);
   lType='Anchor';
case 'xref'
   lType='Xref';
   idName='Linkend';
   endTag=logical(0);
otherwise
   error('Bad LinkType value');
end

out=set(sgmltag,...
   'tag',lType,...
   'att',{idName,linkID},...
   'endtag',endTag);

myChildren=children(c);

if length(myChildren)<1
   if c.att.isEmphasizeText
      out.data=set(sgmltag,...
         'tag','Emphasis',...
         'data',linkText);
   else
      out.data=linkText;
   end
else
   out=[out;runcomponent(myChildren)];
end