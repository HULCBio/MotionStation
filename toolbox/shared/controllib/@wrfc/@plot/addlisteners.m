function addlisteners(this,L)
%ADDLISTENERS  Default implementation.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:11 $

% Initialization. First install generic listeners
if nargin==1
   this.generic_listeners;
else
   this.Listeners = [this.Listeners ; L];
end