function undo(this)
% Undoes transaction.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:54 $
if ~isempty(this.Recorder.Undo)
   % Get last transaction
   LastT = this.Recorder.popundo;

   % Undo it
   undo(LastT)

   % Update plot
   update(this)
end