function rsencof(file_in, file_out, err_cor);
%RSENCOF Encode an ASCII file using Reed-Solomon code.
%   RSENCOF(FILE_IN, FILE_OUT) encodes an ASCII file FILE_IN using
%   (127, 117) Reed-Solomon code. The error-correction capability of
%   this code is 5 for each block. The code is written to FILE_OUT.
%   Both FILE_IN and FILE_OUT are string variables.
%
%   RSENCOF(FILE_IN, FILE_OUT, ERR_COR) encodes an ASCII file FILE_IN
%   using (127, 127-2*ERR_COR) Reed-Solomon code. The error-correction
%   capability is ERR_COR.
%
%   See also RSDECOF.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.11 $


if ~(ischar(file_in) & ischar(file_out))
    error('FILE_IN and FILE_OUT must be strings.')
end
if nargin < 3
    err_cor = 5;        % default error-correction capability
end
N = 127;                % codeword length
K = N - err_cor*2;      % message length

fid = fopen(file_in, 'r');
if fid == -1
    error(sprintf('Cannot open file %s.', file_in));
end
msg = fread(fid, 'uchar');
if fclose(fid) ~= 0
    error(sprintf('Cannot close file %s.', file_in));
end

% Convert msg into a K-column matrix, creating one row at a time,
% and appending char(4) in the last row.
msgLen = length(msg);
msgRow = ceil(msgLen/K);
padded = msgRow*K - msgLen;
msg = reshape([msg; repmat(4, padded, 1)], K, msgRow).';

code = encode(msg, N, K, 'rs/decimal').';

fid = fopen(file_out, 'w');
if fid == -1
    error(sprintf('Cannot open file %s.', file_out));
end
fwrite(fid, code, 'uchar');
if fclose(fid) ~= 0
    error(sprintf('Cannot close file %s.', file_out));
end
return;

% [EOF]
