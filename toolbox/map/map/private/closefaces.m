function [lat,lon] = closefaces(latin,lonin)
%CLOSEFACES closes all faces of a polygon

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:22 $

[lat,lon]=deal(latin,lonin);

if ~iscell(lat)
   [lat,lon]=polysplit(lat,lon);      
end
   
   
for i=1:length(lat)
   [latface,lonface]=deal(lat{i},lon{i});
   [latfacecell,lonfacecell]=polysplit(latface,lonface);
      
   for j=1:length(latfacecell)
      
      % close open polygons        
      if latfacecell{j}(1) ~= latfacecell{j}(end) | lonfacecell{j}(1) ~= lonfacecell{j}(end)
         latfacecell{j}(end+1)=latfacecell{j}(1);
         lonfacecell{j}(end+1)=lonfacecell{j}(1);
      end
      
   end
   
   
   [lat{i},lon{i}]=polyjoin(latfacecell,lonfacecell);
   
end

if ~iscell(latin)
   [lat,lon] = polyjoin(lat,lon);
end

      
