function catted=horzcat(varargin)
%HORZCAT combines SGMLTAG objects
%   HORZCAT(A,B) where A and B are SGMLTAG objects
%   creates a new object the content of which is
%   A and then B.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:34 $

if length(varargin)>1
   newData={};
   for i=1:length(varargin)
      if isa(varargin{i},'sgmltag') & ...
            isempty(varargin{i}.tag) & ...
            all(varargin{i}.opt==[1 1 1 0])
         if iscell(varargin{i}.data)
            newData={newData{:} varargin{i}.data{:}};
         else
            newData{end+1}=varargin{i}.data;
         end
      else
         newData{end+1}=varargin{i};
      end
   end
   catted=sgmltag(newData);
else
   catted=varargin{1};
end
