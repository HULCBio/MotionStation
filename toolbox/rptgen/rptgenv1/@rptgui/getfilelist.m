function fList=getfilelist(g,listType)
%GETFILELIST returns a list of Setup Files
%   FLIST=GETFILELIST(G,TYPE) returns a cell array containing
%   a list of all files open in the Setup File Editor.  TYPE
%   is the type of list requested.  Type may be any of the
%   following strings:
%
%   'Fullpath' - full path name of the setup files (default)
%   'Name'     - file name of the setup files
%   

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:59 $

%check to see if the editor is already open

sfeHandle=findall(allchild(0),'flat','Tag','Setup File Editor');

if isempty(sfeHandle)
   fList={};
else
   
   if nargin<2
      listType='fullpath';
   end
   
   fList=cell(length(g.ref.OpenSetfiles),1);
   
   for i=1:length(g.ref.OpenSetfiles)   
      windowS=get(g.ref.OpenSetfiles(i),'UserData');
      
      switch lower(listType)
      case 'name'
         [path,fList{i},ext,ver]=fileparts(...
            windowS.ref.Path);
         
         if isempty(fList{i})
            fList{i}='Unnamed';
         end
         
      otherwise
         fList{i}=windowS.ref.Path;
      end
      
   end
end
