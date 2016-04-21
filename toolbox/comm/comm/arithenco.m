function code = arithenco(seq, counts)
%ARITHENCO Encode a sequence of symbols using arithmetic coding.
%   CODE = ARITHENCO(SEQ, COUNTS) generates binary arithmetic code 
%   corresponding to the sequence of symbols specified in the vector SEQ. 
%   The vector COUNTS contains the symbol counts (the number of times each
%   symbol of the source's alphabet occurs in a test data set) and represents
%   the source's statistics.
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
%   See also ARITHDECO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $ $Date: 2002/06/17 12:22:10 $

%   References:
%         [1] Sayood, K., Introduction to Data Compression, 
%         Morgan Kaufmann, 2000, Chapter 4, Section 4.4.3.
         
% Input argument checks
error(nargchk(2, 2, nargin));

% Output argument checks
error(nargoutchk(0, 1, nargout));

% Check parameters
eStr = errorchk(seq, counts);
if (eStr.ecode == 1)
    error(eStr.emsg);
end

% Check the incoming orientation and adjust if necessary
[row_s, col_s] = size(seq);
if (row_s > 1),
    seq = seq.';
end

[row_c, col_c] = size(counts);
if (row_c > 1),
    counts = counts.';
end

% Compute the cumulative counts vector from the counts 
cum_counts = [0, cumsum(counts)];

% Compute the Word Length required.
total_count = cum_counts(end);
N = ceil(log2(total_count)) + 2;

% Initialize the lower and upper bounds.
dec_low = 0;
dec_up = 2^N-1;
E3_count = 0;

% Obtain an over estimate for the length of CODE and initialize CODE
code_len = length(seq) * ( ceil(log2(length(counts))) + 2 ) + N;
code = zeros(1, code_len);
code_index = 1;

% Loop for each symbol in SEQ
for k = 1:length(seq)

    symbol = seq(k);
    % Compute the new lower bound
    dec_low_new = dec_low + floor( (dec_up-dec_low+1)*cum_counts(symbol+1-1)/total_count );

    % Compute the new upper bound
    dec_up = dec_low + floor( (dec_up-dec_low+1)*cum_counts(symbol+1)/total_count )-1;

    % Update the lower bound
    dec_low = dec_low_new;
    
    % Check for E1, E2 or E3 conditions and keep looping as long as they occur.
    while( isequal(bitget(dec_low, N), bitget(dec_up, N)) || ...
        (isequal(bitget(dec_low, N-1), 1) && isequal(bitget(dec_up, N-1), 0) ) ),
        
        % If it is an E1 or E2 condition,
        if isequal(bitget(dec_low, N), bitget(dec_up, N)),

            % Get the MSB
            b = bitget(dec_low, N);
            code(code_index) = b;
            code_index = code_index + 1;
        
            % Left shifts
            dec_low = bitshift(dec_low, 1) + 0;
            dec_up = bitshift(dec_up, 1) + 1;
            
            % Check if E3_count is non-zero and transmit appropriate bits
            if (E3_count > 0),
                % Have to transmit complement of b, E3_count times.
                code(code_index:code_index+E3_count-1) = bitcmp(b, 1).*ones(1, E3_count);
                code_index = code_index + E3_count;
                E3_count = 0;
            end

            % Reduce to N for next loop
            dec_low = bitset(dec_low, N+1, 0);
            dec_up  = bitset(dec_up, N+1, 0);
            
        % Else if it is an E3 condition    
        elseif ( (isequal(bitget(dec_low, N-1), 1) && ...
            isequal(bitget(dec_up, N-1), 0) ) ),
            
            % Left shifts
            dec_low = bitshift(dec_low, 1) + 0;
            dec_up  = bitshift(dec_up, 1) + 1;

            % Reduce to N for next loop
            dec_low = bitset(dec_low, N+1, 0);
            dec_up  = bitset(dec_up, N+1, 0);
            
            % Complement the new MSB of dec_low and dec_up
            dec_low = bitxor(dec_low, 2^(N-1) );
            dec_up  = bitxor(dec_up, 2^(N-1) );
            
            % Increment E3_count to keep track of number of times E3 condition is hit.
            E3_count = E3_count+1;
        end
    end
end
 
% Terminate encoding
bin_low = de2bi(dec_low, N, 'left-msb');
if E3_count==0,
    % Just transmit the final value of the lower bound bin_low       
    code(code_index:code_index + N - 1) = bin_low;
    code_index = code_index + N;
else
   % Transmit the MSB of bin_low. 
   b = bin_low(1);
   code(code_index) = b;
   code_index = code_index + 1;
   
   % Then transmit complement of b (MSB of bin_low), E3_count times. 
   code(code_index:code_index+E3_count-1) = bitcmp(b, 1).*ones(1, E3_count);
   code_index = code_index + E3_count;

   % Then transmit the remaining bits of bin_low
   code(code_index:code_index+N-2) = bin_low(2:N);
   code_index = code_index + N - 1;
end          

% Output only the filled values
code = code(1:code_index-1);

% Set the same output orientation as seq
if (row_s > 1)
    code = code.';
end

%----------------------------------------------------------
function eStr = errorchk(seq, counts)
% Function for validating the input parameters. 

eStr.ecode = 0;
eStr.emsg = '';

% Check to make sure a vector has been entered as input and not a matrix
if (length(find(size(seq)==1)) ~= 1)
    eStr.emsg = ['The symbol sequence parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;    
end

% Check to make sure a character array is not specified for SEQ
if ischar(seq)
    eStr.emsg = ['The symbol sequence parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;    
end

% Check to make sure that finite positive integer values (non-complex) are 
% entered for SEQ
if ~all(seq > 0) || ~all(isfinite(seq)) || ~isequal(seq, round(seq)) || ...
    ~isreal(seq)
    eStr.emsg = ['The symbol sequence parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;    
end

if length(find(size(counts)==1)) ~= 1
    eStr.emsg = ['The symbol counts parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;    
end

% Check to make sure that finite positive integer values (non-complex) are
% entered for COUNTS
if ~all(counts > 0) || ~all(isfinite(counts)) || ~isequal(counts, round(counts)) || ...
     ~isreal(counts)
    eStr.emsg = ['The symbol counts parameter must be a vector of positive ',...
                 'finite integers.'];
    eStr.ecode = 1; return;    
end

% Check to ensure that the maximum value in the SEQ vector is less than or equal
% to the length of the counts vector COUNTS.
if max(seq) > length(counts)
    eStr.emsg = ['The symbol sequence parameter can take values only between',...
                 ' 1 and the length of the symbol counts parameter.'];
    eStr.ecode = 1; return;    
end

% [EOF]
