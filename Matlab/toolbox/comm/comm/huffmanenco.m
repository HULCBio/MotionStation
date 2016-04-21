function enco = huffmanenco(sig, dict)
%HUFFMANENCO Encode an input signal using Huffman coding algorithm.
%    
%    ENCO = HUFFMANENCO(SIG, DICT) encodes the input signal, SIG, based on 
%    the code dictionary, DICT. The code dictionary is generated using the
%    HUFFMANDICT function. Each of the symbols appearing in SIG must be
%    present in the code dictionary, DICT. The SIG input can be a numeric
%    vector or a single-dimensional cell array containing alphanumeric
%    values.
%    
%    For example:
%         % Create a Huffman code dictionary using HUFFMANDICT.
%           [dict,avglen] = huffmandict([1:6],[.5 .125 .125 .125 .0625 .0625])
%         % Define a signal of valid letters.
%           sig = [ 2 1 4 2 1 1 5 4 ]
%         % Encode the signal using the Huffman code dictionary.
%           sig_encoded = huffmanenco(sig,dict)
%         
%         % Define an alphanumeric signal in cell array form.
%         sig = {'a2', 44, 'a3', 55, 'a1'}
%         % Define a dictionary . Codes for signal letters must be numeric.
%         dict = {'a1',[0]; 'a2',[1,0]; 'a3',[1,1,0]; 44,[1,1,1,0]; 55,[1,1,1,1]}
%         sig_encoded = huffmanenco(sig,dict)
%    
%    See also HUFFMANDICT, HUFFMANDECO.

%    References:
%        [1] Sayood, K., Introduction to Data Compression, 
%            Morgan Kaufmann, 2000, Chapter 3, Section 3.2. 
%            ISBN: 1-55860-558-4
%    Copyright 1996-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2004/03/30 13:01:43 $

% Error checking ------------------------

msg=nargchk(2,2, nargin);
if ( msg )
	error('comm:huffmanenco:InputArgumentCount', msg)
end

% check if the input is a vector
[m,n] = size(sig);
if ( m ~= 1 && n ~= 1)
    error('comm:huffmanenco:VectorInputSignal', 'The input signal must be a vector.');
end

% Use private function to check dictionary validity
checkDictValidity(dict);

% End of error checking -----------------


if (~iscell(sig) )
	[m,n] = size(sig);
	sig = mat2cell(sig, ones(1,m), ones(1,n) );
end

% Find the size of the largest element in the dictionary, for preallocation
% purposes
maxSize = 0;
dictLength = size(dict,1);
for i = 1 : dictLength
    tempSize = size(dict{i,2},2);
    if (tempSize > maxSize)
        maxSize = tempSize;
    end
end

% Preallocate memory for enco
enco = zeros(1, length(sig)*maxSize);

idxCode = 1;
for i = 1 : length(sig)
    
    % For each signal value, search sequentially through the dictionary to
    % find the code for the given signal
    tempcode = [];
    for j = 1 : dictLength
        if( sig{i} == dict{j,1} )
            tempcode = dict{j,2};
            break;
        end
    end
    
    lenCode = length(tempcode);
    if (lenCode == 0)
		error('comm:huffmanenco:CodeNotFound', ...
            ['The Huffman dictionary provided does not have the codes for all the input signals.'])
    end
    enco(idxCode : idxCode+lenCode-1) = tempcode;
    idxCode = idxCode + lenCode;
end

% Strip off the unused vector elements
enco = enco(1:idxCode-1);

if( n == 1 )        % if input was a column vector
    enco = enco';   % convert the encoded signal to a column vector
end

% EOF -- huffmanenco