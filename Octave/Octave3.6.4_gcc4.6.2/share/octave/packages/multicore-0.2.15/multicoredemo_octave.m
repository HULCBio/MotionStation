% Another test for MULTICORE on Octave
% By Chuong Nguyen 2007-10-12

common_dir = '/tmp'; % folder for shared parameter files
is_multiprocess = 1; % if 1, allow a secondary process
maxMasterEvaluations = inf; % if inf, main process runs until finish

%% Prepare input/output data
N = 20;
parameterCell = cell(1,N);
resultCell = cell(size(parameterCell,2),1);
for k = 1:N
	x.a = k;
	x.b = k;
	x.str = 'This is a test';
	parameterCell{1,k} = x;
end

disp('Processing with a single process')

%% Single-process processing
tic
for k=1:size(parameterCell,2)
	resultCell{k} = testfun_octave(parameterCell{k});
end
toc
resultCell


disp('Processing with 2 processes')

resultCell = [];
resultCell = cell(size(parameterCell,2),1);

%% Open a octave process to run a secondary thread on a multicore computer
if (is_multiprocess)
	[in0, out0, pid0] = popen2 ("octave", "-q");
	% fputs (in0, "startmulticoreslave('/tmp');\n");
	input_str = ['startmulticoreslave(''',common_dir,''');'];
	fputs (in0, input_str);
	fputs (in0, sprintf('\n'));
else
	disp('Warning: no secondary process, only the main process runs. ')
end

%% Multi-process processing if possible
tic
resultCell = startmulticoremaster(@testfun_octave, parameterCell,...
								 common_dir, maxMasterEvaluations);
toc
resultCell

%% Close the secondary process
if (is_multiprocess)
	fclose(in0)
	fclose(out0)
%	pclose(pid0) % doesn't work with this software-2.9.16
%	[err, msg] = kill (pid0, 2)
end


