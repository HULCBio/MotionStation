function cObj = hgbin(HGHandle)
%HGBIN/HGBIN Make hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/15 21:12:52 $

if nargin==0
   cObj.Class = 'hgbin';
   cObj.Items = [];
   cObj.InsertPt = [];
   cObj.ResetParent = [];
   cObj = class(cObj,'hgbin', scribehgobj);
   return
end

HGObj = scribehgobj(HGHandle);
cObj.Class = 'hgbin';
cObj.Items = [];
cObj.InsertPt = -1;  % means insert at end;
cObj.ResetParent = 1;
cObj = class(cObj,'hgbin', HGObj);
