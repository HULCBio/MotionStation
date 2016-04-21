function out=execute(c)
%EXECUTE generate report output
%   OUTPUT=EXECUTE(CRG_IMPORT_FILE)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:05 $

fName = parsevartext(c.rptcomponent,c.att.FileName);

if strcmp(c.att.ImportType,'external')
    %give a fully qualified path if possible
    fullName = which(fName);
    if ~isempty(fullName)
        fName = fullName;
    end
    fName = strrep(fName,'\','/');
    
    out = char(javaMethod('importExternalFile',...
        'com.mathworks.toolbox.rptgencore.docbook.FileImporter',...
        fName));
    c.rptcomponent.ScanDocumentForImports=logical(1);
    return;
end

out='';

fid=fopen(fName,'r');
if fid>0
   out=char(fread(fid,inf,'char'));
   fclose(fid);
   
   if ~isempty(out)
      out=strrep(out',char(13),'');
      
      switch c.att.ImportType
      case 'text'
      case 'para-lb'
         out=DelimitedParagraph(out,1);
      case 'para-emptyrow'
         out=DelimitedParagraph(out,2);
      case 'honorspaces'
         out=set(sgmltag,...
            'tag','LiteralLayout',...
            'data',out,...
            'indent',logical(0));
      case 'fixedwidth'
         out=set(sgmltag,...
            'tag','ProgramListing',...
            'data',out,...
            'indent',logical(0));
      case 'docbook'
         out=set(sgmltag,...
            'data',out,...
            'isSGML',logical(1));
         %tells sgmltag/char not to strrep <,&,nbsp
      end
   else
      status(c,sprintf('Warning - File %s contains no ASCII text.',c.att.FileName),2);
   end
else
   status(c,sprintf('Error - Could not open file %s.',c.att.FileName),1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=DelimitedParagraph(in,numDelim);

%UNIX carriage returns are char(10)
%PC carriage returns are char([13 10]);  We filtered
%out 13's previously

delim=char(10*ones(1,numDelim));
delimLoc=[1-numDelim findstr(in,delim) length(in)+1];

out={};
for i=1:length(delimLoc)-1
   delimString=in(delimLoc(i)+numDelim:delimLoc(i+1)-1);
   if ~all(isspace(delimString))
      out{end+1}=set(sgmltag,...
         'tag','Para',...
         'data',delimString);
   end
end