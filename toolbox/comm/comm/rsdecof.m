function rsdecof(file_in, file_out, err_cor);
%RSDECOF Decode an ASCII file that was encoded using Reed-Solomon code.
%   RSDECOF(FILE_IN, FILE_OUT) decodes an ASCII file FILE_IN using
%   (127, 117) Reed-Solomon code. The error-correction capability of
%   this code is 5 for each block. The decoded message is written to
%   FILE_OUT. Both FILE_IN and FILE_OUT are string variables. FILE_IN
%   should be the output processed by RSENCOF.
%
%   RSDECOF(FILE_IN, FILE_OUT, ERR_COR) decodes an ASCII file FILE_IN
%   using (127, 127-2*ERR_COR) Reed-Solomon code. The error-correction
%   capability is ERR_COR.
%
%   See also RSENCOF.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $

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
code = fread(fid, 'uchar');
if fclose(fid) ~= 0
    error(sprintf('Cannot close file %s.', file_in));
end

% Convert code into an N-column matrix, creating one row at a time,
% and appending char(4) in the last row.
codeLen = length(code);
codeRow = ceil(codeLen/N);
padded = codeRow*N - codeLen;
code = reshape([code; repmat(4, padded, 1)], N, codeRow).';
if padded > 0
    warnmsg =['The code length is different from original encoded file.',...
    '\n         This may cause decode error.'];
    warning('comm:rsdecof:codeLength', sprintf(warnmsg));
end

msg = decode(code, N, K, 'rs/decimal').';

fid = fopen(file_out, 'w');
if fid == -1
    error(sprintf('Cannot open file %s.', file_out));
end
fwrite(fid, msg(1:codeRow*K-padded), 'uchar');
if fclose(fid) ~= 0
    error(sprintf('Cannot close file %s.', file_out));
end

return;

% [EOF]
