function [Vars,Containers,LinkIndex] = utGetVisibleVars(this)
%UTGETVISIBLEVARS  Collects variables visible from root node.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:24 $
Vars = getvars(this);
Containers = this.Data_;
LinkIndex = zeros(size(Vars));
if ~isempty(this.Children_)
   LinkCount = 1;
   for ct=1:length(this.Children_)
      c = this.Children_(ct);
      if strcmp(c.Transparency,'off')
         % Opaque data link
         Vars = [Vars ; c.Alias];
         Containers = [Containers ; c];
         LinkIndex = [LinkIndex ; zeros(size(c))];
      elseif ~isempty(c.LinkedVariables)
         % Follow link and include all variables and links in the 
         % immediate children
         cv = [getvars(c.Template) ; getlinks(c.Template)];
         ncv = length(cv);
         Vars = [Vars ; cv];
         Containers = [Containers ; repmat(c,[ncv 1])];
         LinkIndex = [LinkIndex ; repmat(LinkCount,[ncv 1])];
         LinkCount = LinkCount+1;
      end
   end
end