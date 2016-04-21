function tran_func = sim2logi(sim_file);
%SIM2LOGIC Convert a Simulink block diagram to convolution code logic representation.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       TRAN_FUNC = SIM2LOGI(SIM_FILE) reads in a Simulink block diagram file
%       specified in the string SIM_FILE. The function outputs TRAN_FUNC in
%       the non-linear form. Please refer the user's guide for the 
%       nonlinear transfer function format.
%
%       See also SIM2TRAN, SIM2GEN

%       Wes Wang 12/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.16 $

feval(sim_file, [], [], [], 'compile');
feval(sim_file, [], [], [], 'all');
ext = feval(sim_file, [], [], [], 'sizes');

%eval(['ext = ' sim_file '(0, [], [], 0);']);
M = ext(2); %state number
N = ext(3); %ouptut number
K = ext(4); %input number

x = []; y = [];
for i = 0 : 2^K - 1
    % input index
    % u = mat2str(de2bi(i, K));
    u = de2bi(i, K);

    for j = 0 : 2^M - 1
        % state index
        % x0 = mat2str(de2bi(j, M));
        x0 = de2bi(j, M);

        % eval(['ext = ' sim_file '(1, ' x0 ',' u ', 3);']);
        ext = feval(sim_file, 1, x0, u, 'outputs');
        y = [y; ext'];

        % eval(['ext = ' sim_file '(1, ' x0 ',' u ', 7);']);
        ext = feval(sim_file, 1, x0, u, 'update');
        x = [x; ext'];
    end;
end;
% release the compiled model
feval(sim_file, [], [], [], 'term');

% makeup the data structure.
if (size(x, 2) == 1) & (size(y, 2) == 1)
    tran_func = [ [Inf N]; [M K];[x y]];
elseif size(x, 2) == 1
    tran_func = [ [Inf N]; [M K];[x bi2de(y)]];
elseif size(y, 2) == 1
    tran_func = [ [Inf N]; [M K];[bi2de(x) y]];
else
    tran_func = [ [Inf N]; [M K];[bi2de(x) bi2de(y)]];
end;
