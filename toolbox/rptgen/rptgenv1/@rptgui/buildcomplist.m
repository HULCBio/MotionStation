function g=buildcomplist(g,forceBuild)
%BUILDCOMPLIST creates the list of all components
%   G=BUILDCOMPLIST(G) creates the following fields
%   G.ref.allcomps - all components on path
%   G.ref.compTypes - all component types on path
%   G.ref.complist - formatted treeview of components
%
%   The first two lists are updated when the setup file
%   editor is started or when called with G=BUILDCOMPLIST(G,1);
%
%   The third list is updated when the setup file editor is
%   started or when a category in the "add components" list
%   is expanded or collapsed.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:52 $

%--------1---------2---------3---------4---------5---------6---------7---------8

if nargin<2
   forceBuild=logical(0);
end

if isempty(g.ref.allcomps) | forceBuild
   g.ref.Pointer='arrow';
   set(g.h.fig,'Pointer','watch')
   g.ref.allcomps=allcomps(g.rptparent);
   g.ref.compTypes=allcomptypes(g.rptparent);
end

cindex=1;
for i=1:length(g.ref.compTypes)
   matchIndex=find(strcmp({g.ref.allcomps.Type},g.ref.compTypes(i).Type));
   if ~isempty(matchIndex)
      if g.ref.compTypes(i).Expand
         complist(cindex)=struct('Name',g.ref.compTypes(i).Fullname,...
            'LBstring',['[ -] ',upper(g.ref.compTypes(i).Fullname)],...
            'compname',i);
         cindex=cindex+1;
         for j=1:length(matchIndex)
            complist(cindex)=struct('Name',g.ref.allcomps(matchIndex(j)).Name,...
               'LBstring',['      ',g.ref.allcomps(matchIndex(j)).Name],...
               'compname',g.ref.allcomps(matchIndex(j)).Class);
            cindex=cindex+1;
         end   
      else
         complist(cindex)=struct('Name',g.ref.compTypes(i).Fullname,...
            'LBstring',['[+] ',upper(g.ref.compTypes(i).Fullname)],...
            'compname',i);
         cindex=cindex+1;
      end
   end
end

g.ref.complist=complist;