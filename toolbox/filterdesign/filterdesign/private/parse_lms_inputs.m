function [S,error_msg,warn_msg] = parse_lms_inputs(x,d,S)
% Parse the inputs to the ADAPTLMS function

%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 15:38:57 $

% Assign default error and warning messages.
error_msg = ''; warn_msg = ''; 

if ~isequal(length(x),length(d))
    error_msg = 'Input and desired signal vectors should be of same length.';
    return;
end

% Check if filter_taps are initialized.
if ~isfield(S,'coeffs')
	error_msg = ['Filter coefficients should be initialized to a ', ...
			'vector of length equal to the filter order plus one.'];
	return; 
end

% Check if FIR filter initial conditions are specified.
if ~isfield(S,'states')
	S.states = zeros(length(S.coeffs)-1,1);
end
% Make sure that FIR filter initial conditions are of correct length.
if ~isequal(length(S.states),length(S.coeffs)-1),
	error_msg = ['FIR initial states should be of length equal to ', ... 
			'the filter order.'];
	return;     
end

% Check if the LMS step size is specified.
if ~isfield(S,'step')
	error_msg = 'Adaptation step size is not specified.';
	return;
end

% Check if a leakage factor is specified.
if ~isfield(S,'leakage')
	S.leakage = 1;
end

% Check if offset is specified (used only in nlms).
if ~isfield(S,'offset')
	S.offset = 0;
end

% Complete structure assignment.
S.iter = 0;  % Initialize iteration count.


% EOF
