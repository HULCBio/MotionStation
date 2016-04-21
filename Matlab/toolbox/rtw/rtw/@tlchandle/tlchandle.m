function t=tlchandle(h)
%TLCHANDLE represents a tlc context handle
%   TLCHANDLE is a wrapper object which contains a
%   single integer representing a tlc context
%   handle.  It allows the use of the syntax
%   READ(H,'FILENAME.RTW') instead of
%   TLC('read',H,'FILENAME.RTW').
%
%   X=TLCHANDLE with no arguments causes a
%   new tlc context to be created.
%   X=TLCHANDLE(A) where A is an integer converts
%   the integer into a TLCHANDLE object.
%
%   See also TLCHANDLE/CLOSE, TLCHANDLE/EXECFILE,
%   TLCHANDLE/EXECSTRING, TLCHANDLE/GET,
%   TLCHANDLE/QUERY, TLCHANDLE/READ, TLCHANDLE/SET

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:56:42 $

if nargin<1
   t.Handle=tlc('new');
   t=class(t,'tlchandle');
elseif isa(h,'tlchandle')
   t=h;
elseif isa(h,'double')
   t.Handle=h;
   t=class(t,'tlchandle');
else
   t.Handle=[];
   t=class(t,'tlchandle');
end

