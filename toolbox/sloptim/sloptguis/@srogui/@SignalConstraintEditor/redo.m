function redo(this)
% Redoes transaction.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:47 $
if ~isempty(this.Recorder.Redo)
   % Get last transaction
   LastT = this.Recorder.popredo;

   % Redo it (will perform required updating)
   redo(LastT)

   % Update plot
   update(this)
end