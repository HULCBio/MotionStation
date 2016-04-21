function addlisteners(this,L)
%  ADDLISTENERS  Installs additional listeners for @nicholsplot class.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:16 $

if nargin == 1
  % Initialization. First install generic listeners
  this.generic_listeners;

  % Add @nicholsplot specific listeners
  % set(L, 'CallbackTarget', this);
else
  this.Listeners = [this.Listeners ; L];
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%
