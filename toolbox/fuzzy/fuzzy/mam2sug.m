function out_fismat = mam2sug(fismat)
%MAM2SUG Transform from Mamdani to Sugeno fuzzy inference system.

%MAM2SUG Transform Mamdani FIS into a Sugeno FIS.
%   Synopsis
%   sug_fis=mam2sug(mam_fis)
%   Description
%   mam2sug(mam_fis) transforms a (not necessarily single output) Mamdani FIS
%   structure mam_fis into a Sugeno FIS structure sug_fis. The returned Sugeno
%   system has constant output membership functions. These constants are
%   determined by the centroids of the consequent membership functions of the
%   original Mamdani system. The antecedent remains unchanged.
%   	Examples
%   mam_fismat = readfis('mam22.fis');
%   sug_fismat = mam2sug(mam_fismat);
%   subplot(2,2,1); gensurf(mam_fismat, [1 2], 1);
%   title('Mamdani system (Output 1)');
%   subplot(2,2,2); gensurf(sug_fismat, [1 2], 1);
%   title('Sugeno system (Output 1)');
%   subplot(2,2,3); gensurf(mam_fismat, [1 2], 2);
%   title('Mamdani system (Output 2)');
%   subplot(2,2,4); gensurf(sug_fismat, [1 2], 2);
%   title('Sugeno system (Output 2)');

%   Roger Jang, 6-28-95
%   Copyright 1994-2002 The MathWorks, Inc. 
% $Revision: 1.10 $

if nargin < 1,
	error('Need a FIS matrix as an input argument.');
end
if ~strcmp(fismat.type, 'mamdani'),
	error('Given FIS matrix is not a Mamdani system!');
end

in_n = length(fismat.input);
out_n = length(fismat.output);
defuzzmethod = fismat.defuzzMethod;
for i = 1:out_n,
	mf_n = length(fismat.output(i).mf);
	range = fismat.output(i).range;
	x = linspace(range(1), range(2), 101);
	for j = 1:mf_n,
		mf = evalmf(x,... 
			fismat.output(i).mf(j).params,...
			fismat.output(i).mf(j).type);
		constant = defuzz(x, mf, defuzzmethod);
		fismat.output(i).mf(j).type='linear';
		fismat.output(i).mf(j).params=[zeros(1, in_n) constant];
	end
end
fismat.type='sugeno';
fismat.defuzzMethod='wtaver';
out_fismat = fismat;
