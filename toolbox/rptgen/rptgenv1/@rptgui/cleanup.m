function varargout=cleanup(g)
%CLEANUP - Strips RPTGUI object of data
%   G=CLEANUP(G) strips the RPTGUI object "G"
%     CLEANUP(G) strips G and saves it in RGSTOREGUI
%
%   CLEANUP is called when exiting the setup file editor.
%   After exit, an RPTGUI object stays in RGSTOREGUI,
%   but it is empty.
%
%   See also RGSTOREGUI, RPTGUI, SETEDIT

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:54 $

g.s=[];
g.c=[];
g.h=[];
g.ref.OpenSetfiles=[];
g.ref.allcomps=[];
g.ref.ObjectBrowserHandle=[];

if nargout>1
   error('Too many output arguments');
elseif nargout==1
   varargout{1}=g;
else
   rgstoregui(g);
end