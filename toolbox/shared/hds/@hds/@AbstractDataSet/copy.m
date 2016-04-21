function D = copy(this,varargin)
%COPY  Copy method for data sets.
%
%   D2 = COPY(this) creates a copy of the data set this.
%
%   D2 = COPY(this,'DataCopy','off') copies the skeleton without the data.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:57 $

% Defaults 
DataCopy = true;

% Parse options
ntail = nargin-1;
nopts = round(ntail/2);
if ntail~=2*nopts
   error('Options must come in property/value pairs.')
end
for ct=1:2:ntail
   Option = varargin{ct};
   if strncmpi(Option,'d',1)
      % DataCopy
      DataCopy = strcmpi(varargin{ct+1},'on');
   end
end
   
% Copy skeleton, excluding parent
D = feval(class(this),getvars(this),getlinks(this));

% Copy grid
if DataCopy
   D.Grid_ = this.Grid_;
else
   D.setgrid(this.Grid_.Variable);
end

% Copy containers
% UDDREVISIT
% for ct=1:length(this.Data_)
%    D.Data_(ct) = copy(this.Data_(ct),DataCopy);
% end
Data = D.Data_;
for ct=1:length(this.Data_)
   Data(ct,1) = copy(this.Data_(ct),DataCopy);
end
D.Data_ = Data;

% UDDREVISIT
% for ct=1:length(this.Children_)
%    D.Children_(ct) = copy(this.Children_(ct),DataCopy);
% end
Links = D.Children_;
for ct=1:length(this.Children_)
   Links(ct) = copy(this.Children_(ct),DataCopy);
end
D.Children_ = Links;

