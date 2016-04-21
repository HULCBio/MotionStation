function checkDictValidity(a)
% Check if the input dictionary is a valid Huffman dictionary. Huffman code
% satisfies the prefix condition. Thus no code should be a prefix of other 
% code.

% Copyright 2004 The MathWorks, Inc.

if ( ~iscell(a) )
	error('comm:checkDictValidity:InvalidDictionaryFormat', ...
        'The Huffman dictionary has to be a 2 column cell array.')
end
[m,n] = size(a);
if (n ~= 2)
	error('comm:checkDictValidity:InvalidDictionarySize', ...
        'The Huffman dictionary has to have exactly two columns of data.')
end
try
	if ( ~isa([a{:,2}], 'double') )
		error('comm:checkDictValidity:InvalidCodeType', ...
            'The Huffman codes in the dictionary must be of type double.');
	end
catch
	error('comm:checkDictValidity:InvalidCodeType', ...
        'The Huffman codes in the dictionary must be of type double.');
end

for i=1:m-1                  % compare each entry
	for j=i+1:m              % with the rest
        prefix = [1:min(length(a{i,2}),length(a{j,2}))];
		if all(a{i,2}(prefix)==a{j,2}(prefix))
			error('comm:checkDictValidity:NonPrefixDictionary', ...
                'The Huffman dictionary does not satisfy the prefix condition.')
		end
	end
end