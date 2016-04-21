function step(this, r, varargin)
%  STEP  Update step response data (@respdata) of the response (r = @response)
%        object using the response source (this = @ltisource).
%
%  VARARGIN = Tfinal or time vector, if supplied.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:07 $

% Get new data from the @respsource object.
for ct = 1:length(r.Data)
  % Look for visible+cleared responses in response array
  if isempty(r.Data(ct).Amplitude) & strcmp(r.View(ct).Visible,'on')
    % Get step response data
    d = r.Data(ct);  
    if nargin<3 & strcmp(r.RefreshMode, 'quick')
      % Reuse the current time vector for maximum speed
      [Y,T] = gentresp(this.Model(:,:,ct),'step',r.Data(ct).Time);
    else
      % Regenerate data on appropriate grid based on input arguments
      [Y,T,d.Focus] = gentresp(this.Model(:,:,ct),'step',varargin{:});
    end
    % Store in response data object (@timedata instance)
    d.Time      = T;
    d.Amplitude = Y;
  end
end
