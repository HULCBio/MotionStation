function t=att(t,varargin)
%ATT adds attributes to an SGMLTAG object
%   T=ATT(T,'Att1',Val1,'Att2',Val2....)
%   If an attribute is already defined, ATT will
%   overwrite that attribute with the new value.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:29 $

existnames={t.att{:,1}};

attnames={varargin{1:2:end-1}};
attvals={varargin{2:2:end}};

for i=1:length(attnames)
   row=find(strcmp(existnames,attnames{i}));
   if isempty(row) 
      row=size(t.att,1)+1;
      t.att{row,1}=attnames{i};
      existnames{end+1}=attnames{i};
   else
      row=row(1);
   end
   t.att{row,2}=attvals{i};
end