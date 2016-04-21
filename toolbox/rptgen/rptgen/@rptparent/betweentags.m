function contents=betweentags(p,text,tagname)
%BETWEENTAGS returns text between XML tags

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:11 $

if isnumeric(text)
   fid=text;
   try
      text=char(fread(fid))';
      fclose(fid);
   catch
      text='';
   end
end

contents={};
openTag=['<' tagname '>'];
closeTag=['</' tagname '>'];

openLoc=findstr(text,openTag)+length(openTag);
closeLoc=findstr(text,closeTag)-1;

for i=length(openLoc):-1:1
   contents{i}=text(openLoc(i):closeLoc(i));   
end