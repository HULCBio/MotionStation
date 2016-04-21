function [m, d, s] = gwnoise(m, d, s)
%GWNOISE generate valid mean value, standard deviation and seeds for GWNOISE block.
%	[M, D, S] = GWNOISE(M, D, S) checks input mean M, standard deviation D, and
%	seed S. When they are not valid, converts them to be valid for GWNOISE
%	block, or gives out an error message.
%

%  Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.1.6.1 $

if nargin ~= 3
	error('Input variable must be 3 for GWNOISE.');
end;
m = m(:)';
s = s(:)';
l_m = length(m);
l_s = length(s);
[n_d, m_d] = size(d);
if n_d ~= m_d
	if min(n_d, m_d) == 1
		if any(d < 0)
			error('Standard deviation cannot be negative number.');
		end
		d = diag(d);
	else
		error('Standard deviation for Gaussian noise block is not valid.');
	end;
else
	[n_d, m_d] = chol(d);
	if m_d ~= 0
		error('Standard deviation for Gaussian noise must be positive definite.');
	end;
end;
l_d = length(d);
if ((l_m < l_d) & (l_m ~= 1)) | ((l_m > l_d) & (l_d ~= 1))
	error('The dimensions of the mean and standard deviation for Gaussian noise block are not compatible.');
end;
max_l = max(l_m, l_d);
if l_s < max_l
    new_seed = 1;
    while l_s < max_l
        seed_pos = find(s == new_seed);
        if (length(seed_pos) == 0)
            s = [s, new_seed];
            l_s = length(s);
        end
        new_seed = new_seed + 1;
    end    
elseif l_s > max_l
    if max_l ~= 1
        s = s(1 : max_l);
    else
        d = eye(l_s) * d;
    end;
end;
[d, tmp] = chol(d);
if tmp > 0
    error('Covariance matrix in AWGN noise generator is not a positively defined matrix.');
end;
% end of gwnoise
