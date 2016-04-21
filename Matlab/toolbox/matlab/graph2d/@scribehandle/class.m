function val = class(hndl,varargin)
%SCRIBEHANDLE/CLASS Class method for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/15 21:12:57 $

if nargin==1
   if ~isempty(hndl)
      if length(hndl)>1
         hndl = hndl(1);
      end
      ud = getscribeobjectdata(hndl.HGHandle);
      MLObj = ud.ObjectStore;
      val = class(MLObj);
   else
      val = 'scribehandle';
   end
else
   val = builtin('class',hndl,varargin{:});
end