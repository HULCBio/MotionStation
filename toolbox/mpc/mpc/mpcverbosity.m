function mpcverbosity(value)
%MPCVERBOSITY Change the level of verbosity of the MPC Toolbox
%
%   MPCVERBOSITY ON enables messages displaying default operations taken by
%   the MPC Toolbox during the creation and manipulation of MPC objects.
%
%   MPCVERBOSITY OFF turns messages off (default)
%
%   MPCVERBOSITY just shows the verbosity status

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/10 23:35:31 $

swarn=warning;
verbinit=warning('query','mpc:verbosity:init');
verbinit=verbinit.state;
if strcmp(verbinit,'on'),
    % MPC Verbosity was not initialized yet
    warning('off','mpc:verbosity:init');
    % Set level of verbosity to 'off' by default
    warning('off','mpc:verbosity');
end

if nargin==0 | isempty(value),
    verbose=warning('query','mpc:verbosity');
    verbose=verbose.state;
    disp(sprintf('MPC verbosity level is %s',verbose));
    return
end

if ~ischar(value) | ~ (strcmp(lower(value),'on') | strcmp(lower(value),'off'))
    error('mpc:mpcverbosity:string','Verbosity must be either ''on'' or ''off''');
end

value=lower(value);
warning(value,'mpc:verbosity');