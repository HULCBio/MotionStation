function dseq = arithdeco(code, counts, len)
%ARITHDECO Decode binary code using arithmetic decoding.
%   DSEQ = ARITHDECO(CODE, COUNTS, LEN) decodes the binary arithmetic code
%   in the vector CODE (generated using ARITHENCO) to the corresponding
%   sequence of symbols. The vector COUNTS contains the symbol counts (the
%   number of times each symbol of the source's alphabet occurs in a test
%   data set) and represents the source's statistics. LEN is the number of
%   symbols to be decoded. 
%   
%   Example: 
%     Consider a source whose alphabet is {x, y, z}. A 177-symbol test data 
%     set from the source contains 29 x's, 48 y's and 100 z's. To encode the 
%     sequence yzxzz, use these commands:
%
%       seq = [2 3 1 3 3];
%       counts = [29 48 100];
%       code = arithenco(seq, counts)   
%            
%     To decode this code (and recover the sequence of  
%     symbols it represents) use this command:
%            
%       dseq = arithdeco(code, counts, 5)
%            
%   See also ARITHENCO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2002/04/14 20:12:32 $

%   References:
%         [1] Sayood, K., Introduction to Data Compression, 
%         Morgan Kaufmann, 2000, Chapter 4, Section 4.4.3.

% Input argument check
error(nargchk(3, 3, nargin));

% Output argument check
error(nargoutchk(0, 1, nargout));

% Check parameters
eStr = errorchk(code, counts, len);
if (eStr.ecode == 1)
    error(eStr.emsg);
end

% Check the incoming orientation and adjust if necessary
[row_cd, col_cd] = size(code);
if (row_cd > 1),
    code = code.';
end

[row_c, col_c] = size(counts);
if (row_c > 1),
    counts = counts.';
end

% Compute the cumulative counts vector from the counts vector
cum_counts = [0, cumsum(counts)];

% Compute the Word Length (N) required.
total_count = cum_counts(end);
N = ceil(log2(total_count)) + 2;

% Initialize the lower and upper bounds.
dec_low = 0;
dec_up = 2^N-1;

% Read the first N number of bits into a temporary tag bin_tag
bin_tag = code(1:N);
dec_tag = bi2de(bin_tag, 'left-msb');

% Initialize DSEQ
dseq = zeros(1,len);
dseq_index = 1;

k=N;
ptr = 0;

% This loop runs untill all the symbols are decoded into DSEQ
while (dseq_index <= len)
    
    % Compute dec_tag_new
    dec_tag_new =floor( ((dec_tag-dec_low+1)*total_count-1)/(dec_up-dec_low+1) );
    
    % Decode a symbol based on dec_tag_new
    ptr = pick(cum_counts, dec_tag_new);
    
    % Update DSEQ by adding the decoded symbol
    dseq(dseq_index) = ptr;
    dseq_index = dseq_index + 1;
    
    % Compute the new lower bound
    dec_low_new = dec_low + floor( (dec_up-dec_low+1)*cum_counts(ptr-1+1)/total_count );
    
    % Compute the new upper bound
    dec_up = dec_low + floor( (dec_up-dec_low+1)*cum_counts(ptr+1)/total_count )-1;
    
    % Update the lower bound
    dec_low = dec_low_new;
    
    % Check for E1, E2 or E3 conditions and keep looping as long as they occur.
     while ( isequal(bitget(dec_low, N), bitget(dec_up, N)) | ...
        ( isequal(bitget(dec_low, N-1), 1) & isequal(bitget(dec_up, N-1), 0) ) ),
        
        % Break out if we have finished working with all the bits in CODE
        if ( k==length(code) ), break, end;
        k = k + 1;

        % If it is an E1 or E2 condition, do
        if isequal(bitget(dec_low, N), bitget(dec_up, N)),

            % Left shifts and update
            dec_low = bitshift(dec_low, 1) + 0;
            dec_up  = bitshift(dec_up,  1) + 1;

            % Left shift and read in code
            dec_tag = bitshift(dec_tag, 1) + code(k);

            % Reduce to N for next loop
            dec_low = bitset(dec_low, N+1, 0);
            dec_up  = bitset(dec_up,  N+1, 0);
            dec_tag = bitset(dec_tag, N+1, 0);
        
        % Else if it is an E3 condition        
        elseif ( isequal(bitget(dec_low, N-1), 1) & ...
            isequal(bitget(dec_up, N-1), 0) ),

            % Left shifts and update
            dec_low = bitshift(dec_low, 1) + 0;
            dec_up  = bitshift(dec_up,  1) + 1;

            % Left shift and read in code
            dec_tag = bitshift(dec_tag, 1) + code(k);
            
            % Reduce to N for next loop
            dec_low = bitset(dec_low, N+1, 0);
            dec_up  = bitset(dec_up,  N+1, 0);
            dec_tag = bitset(dec_tag, N+1, 0);
            
            % Complement the new MSB of dec_low, dec_up and dec_tag
            dec_low = bitxor(dec_low, 2^(N-1) );
            dec_up  = bitxor(dec_up,  2^(N-1) );
            dec_tag = bitxor(dec_tag, 2^(N-1) );

        end
    end % end while
end % end while length(dseq)

% Set the same output orientation as code
if (row_cd > 1)
    dseq = dseq.';
end
%-------------------------------------------------------------
function [ptr] = pick(cum_counts, value);
% This internal function is used to find where value is positioned

% Check for this case and quickly exit
if value == cum_counts(end)
    ptr = length(cum_counts)-1;
    return
end

c = find(cum_counts <= value);
ptr = c(end);

%----------------------------------------------------------
function eStr = errorchk(code, counts, len);
% Function for validating the input parameters. 

eStr.ecode = 0;
eStr.emsg = '';

% Check to make sure a vector has been entered as input and not a matrix
if (length(find(size(code)==1)) ~= 1)
    eStr.emsg = ['The binary arithmetic code parameter must be a double ',...
                 'array of zeros and ones only.'];
    eStr.ecode = 1; return;
end

if (length(find(size(counts)==1)) ~= 1)
    eStr.emsg = ['The symbol counts parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;
end

% Check to make sure that CODE is binary
if any(code ~= 1 & code ~= 0)
    eStr.emsg = ['The binary arithmetic code parameter must be a double ',...
                 'array of zeros and ones only.'];
    eStr.ecode = 1; return;
end

% Check to make sure that finite positive integer values (non-complex) are
% entered for COUNTS
if ~all(counts > 0) | ~all(isfinite(counts)) | ~isequal(counts, round(counts)) | ...
    ~isreal(counts)
    eStr.emsg = ['The symbol counts parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;
end

% Check to make sure LEN is scalar
if ~isequal(size(len),[1 1])
    eStr.emsg = 'The number of symbols must be a positive, finite, integer scalar.';
    eStr.ecode = 1; return;
end

% Check to make sure that finite positive integer value (non-complex) is
% entered for LEN
if len < 1 | ~isfinite(len) | (len ~= round(len)) | ~isreal(len)
    eStr.emsg = 'The number of symbols must be a positive, finite, integer scalar.';
    eStr.ecode = 1; return;
end

% EOF
