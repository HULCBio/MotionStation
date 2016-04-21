function resultCell = multicoredemo(multicoreDir)
%MULTICOREDEMO  Test parallel processing on multiple cores.
%   MULTICOREDEMO runs function testfun with 20 different parameters using
%   function STARTMULTICOREMASTER. Open a second Matlab session on a
%   multi-core machine and start function STARTMULTICORESLAVE to see the
%   effect of the parallelization.
%
%   MULTICOREDEMO(DIRNAME) uses directory DIRNAME to put the intermediate
%   files. Use this notation to test the parallelization of different
%   machines that have access to a common directory.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%   See also STARTMULTICOREMASTER, STARTMULTICORESLAVE.

if nargin == 0
	multicoreDir = '';
end

N = 20;
maxMasterEvaluations = inf;

parameterCell = cell(1,N);
for k = 1:N
	parameterCell{1,k} = k;
end

for k = 1:10
	tic
	resultCell = startmulticoremaster(@testfun, parameterCell, multicoreDir, maxMasterEvaluations);
	toc
end
