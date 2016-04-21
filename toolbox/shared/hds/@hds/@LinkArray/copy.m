function A = copy(this,DataCopy)
%COPY  Copy method for @LinkArray.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:39 $
A = hds.LinkArray;
A.Alias = this.Alias;
A.LinkedVariables = this.LinkedVariables;
A.Template = this.Template;
A.Transparency = this.Transparency;
if DataCopy
   A.Links = this.Links;
end
