function rmresponse(this, r)
%RMRESPONSE  Removes a response from the current response plot.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:44 $

% Validate input argument
if ~ishandle(r)
  error('Second argument must be a valid handle.')
end

% Find position of @response object
idx = find(this.Responses == r);

% Delete @response object
if ~isempty(idx)
  delete(this.Responses(idx));
  this.Responses = this.Responses([1:idx-1, idx+1:end]);
end

% Update limits
this.AxesGrid.send('ViewChanged')
