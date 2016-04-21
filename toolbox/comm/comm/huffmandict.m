function [dict,avglen] = huffmandict(sig, prob, varargin)
%HUFFMANDICT Code dictionary generator for Huffman coder.
%    
%    DICT = HUFFMANDICT(SYM, PROB) generates a binary Huffman code
%    dictionary using the maximum variance algorithm for the distinct
%    symbols given by the SYM vector. The symbols can be represented as a
%    numeric vector or single-dimensional alphanumeric cell array. The
%    second input, PROB, represents the probability of occurrence for each
%    of these symbols. SYM and PROB must be of same length.
%    
%    DICT = HUFFMANDICT(SYM, PROB, N) generates an N-ary Huffman code 
%    dictionary using the maximum variance algorithm. N is an integer
%    between 2 and 10 (inclusive) that must not exceed the number of
%    source symbols whose probabilities appear in PROB.
%    
%    DICT = HUFFMANDICT(SYM, PROB, N, VARIANCE) generates an N-ary Huffman
%    code with the specified variance. The possible values for VARIANCE are
%    'min' and 'max'.
%    
%    [DICT, AVGLEN] = HUFFMANDICT(...) returns the average codeword length
%    of the Huffman code. 
%
%    For example:
%          symbols = [1:5] % Alphabet vector                               
%          prob = [.3 .3 .2 .1 .1] % Symbol probability vector              
%          [dict,avglen] = huffmandict(symbols,prob)                          
%
%          % Pretty print the dictionary.
%          temp = dict;
%          for i = 1:length(temp)
%          temp{i,2} = num2str(temp{i,2});
%          end
%          temp
%    
%    See also HUFFMANENCO, HUFFMANDECO.   

%    References:
%        [1] Sayood, K., Introduction to Data Compression,  Morgan
%            Kaufmann, 2000, Chapter 3. ISBN: 1-55860-558-4
%
%    Copyright 1996-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2003/06/23 04:34:04 $ 

ROUND_OFF_ERROR = 1e-6;

n_ary = [];
variance = '';

msg=nargchk(2,4, nargin);
if ( msg )
	error('comm:huffmandict:InputArgumentCount', msg)
end

if nargin > 2
	n_ary = varargin{1};
end
if nargin == 4
	variance = varargin{2};
end

if isempty(n_ary)
    n_ary = 2; % default value is binary encryption
end
if ( variance )
	% if variance contains a non-null string do nothing
else
    variance = 'max'; % default is maximum variance Huffman code
end

% Check if the sig and prob inputs are vectors
if ( min(size(sig)) ~= 1 )
    error('comm:huffmandict:VectorSymbol', 'The symbol input must be a vector')
end

if ( min(size(prob)) ~= 1 )
    error('comm:huffmandict:VectorProbability', 'The probability input must be a vector')
end

% Check if the probability vector is of type double
if ( ~strcmp( class(prob), 'double') )
    error('comm:huffmandict:DoubleProbability', 'The probability vector must be of type double')
end

% Check if any of the elements of probability vector is negative
if ( min( prob ) < 0 )
    error('comm:huffmandict:ProbabilityMinVal', 'Probability of an input symbol cannot be negative')
end

% Check if any of the elements of probability vector is greater than 1
if ( max( prob ) > 1 )
    error('comm:huffmandict:ProbabilityMaxVal', 'Probability of an input symbol cannot be greater than 1')
end


% Check if both signal and probability vectors are of same length
if( length(sig) ~= length(prob) )
    error('comm:huffmandict:SymbolProbabilityLengthMismatch', 'The symbol and probability vector must have the same length');
end

% Make sure that internally all vectors are represented as column vectors
m = size(sig);
if( m(1) == 1 ) 
    sig = sig';
end
m = size(prob); 
prob = prob(:);

if(  abs(sum(prob) - 1 ) > ROUND_OFF_ERROR ) % to take care of the round off error
    error('comm:huffmandict:ProbabilitySum',...
        'The sum of elements of the probability vector must be 1');
end

if ~iscell (sig) && ~isnumeric (sig)
	error('comm:huffmandict:NumericSymbol',...
        'Non-numeric symbols must be represented in a cell array.')
end

if (~( length(n_ary) == 1 && isa(n_ary, 'numeric') ) )
	error('comm:huffmandict:DoubleNAry',...
        'The value for n_ary has to be a numeric scalar.')
end

if ( n_ary < 2 )
    error('comm:huffmandict:MinNAry',...
        'The value of n_ary has to be greater than or equal to 2.')
end

if ( n_ary > 10 )
    error('comm:huffmandict:MaxNAry',...
        'The value of n_ary has to be less than or equal to 10.')
end

if ( (n_ary - floor(n_ary)) > eps )
    error('comm:huffmandict:IntegerNAry',...
        'The value of n_ary has to be a positive integer between 2 and 10.')
end

% Check if the number of input signals is greater than the size
% of the symbols
if( length(sig) < n_ary)
    error('comm:huffmandict:NArySymbolLengthMismatch',...
        'The value for n_ary must be less than or equal to the number of distinct symbols.');
end

% Check if the value for the var is either max or min
if ( ~( (strcmpi(variance, 'max') == 0 || strcmpi(variance, 'min') == 0  )...
		&& length(variance) == 3 ) )
	error('comm:huffmandict:InvalidVariance',...
        'The value for variance has to be either ''min'' or ''max''.')
end

% Make sure that the input symbols are in a cell array format
if ~iscell(sig)
	[m,n] = size(sig);
	sig = mat2cell(sig, ones(1,m), ones(1,n)) ;
end

% Check if all the input symbols are either alphabets or numbers or a
% combination of the two
for i=1:length(sig)
	isalphanumeric(i) = ischar(sig{i}) || isnumeric(sig{i});
end
if ( min(isalphanumeric) == 0 )
	error('comm:huffmandict:InvalidSymbolData',...
        'One or more symbols are neither numeric nor character strings.')
end

% Check if the each symbol in the first input is unique
for i = 1:length(sig)-1
	pilotpoint = sig{i};
	for j = i+1:length(sig)
		if length(pilotpoint) == length(sig(j)) && min(pilotpoint == sig{j})
			error('comm:huffmandict:RepeatedSymbols', 'Source symbols repeat')
		end
	end
end
%% === Input parameters are all set ===

%% === Create the dictionary ===
% Create tree nodes with the signals and the corresponding probabilities
huff_tree = struct('signal', [], 'probability', [],...
    'child', [], 'code', [], 'origOrder', -1);
for i=1:length( sig )
    huff_tree(i).signal = sig{i}; 
    huff_tree(i).probability = prob(i); 
	huff_tree(i).origOrder = i;
end

% Sort the signal and probability vectors based on ascending order of
% probability
[s, i] = sort(prob);
huff_tree = huff_tree(i);

huff_tree = create_tree(huff_tree, n_ary, variance); % create a Huffman tree
[huff_tree,dict,avglen] = create_dict(huff_tree,{},0, n_ary); % create the codebook

% The next few lines of code are to sort the dictionary.
% If sorting based on original order then use dict{:,4}.
% If sorting based on the lenght of code, then use  dict{:,3}.
[dictsort,dictsortorder] = sort([dict{:,4}]);
finaldict = {};
for i=1:length(dictsortorder)
    finaldict{i,1} = dict{dictsortorder(i), 1};
    finaldict{i,2} = dict{dictsortorder(i), 2};
end
dict = finaldict;

%--------------------------------------------------------------------------
%% Function: huff_tree
% Input: An array of structures to be arranged into a Huffman tree
% Utility: This is a recursive algorithm to create the Huffman Code
%          tree. This is a recursive function
function huff_tree = create_tree(huff_tree, n_ary, variance)

% if the length of huff_tree is 1, it implies there is no more than one
% node in the array of nodes. This is the termination condition for the
% recursive loop
if( length(huff_tree) <= 1)
    return;
end

% Combine the first n_ary (lowest probability) number of nodes under one
% parent node, remove these n_ary nodes from the list of nodes and add
% the new parent node that was just created
temp = struct('signal', [], 'probability', 0, ...
    'child', [], 'code', []);
for i=1:n_ary
    if( length(huff_tree) == 0), break; end
    temp.probability = temp.probability + huff_tree(1).probability; % for ascending order
    temp.child{i} = huff_tree(1);
	temp.origOrder = -1;
    huff_tree(1) = [];
end
if( strcmpi(variance, 'min') == 1 )
    huff_tree = insertMinVar(huff_tree, temp);
else
    huff_tree = insertMaxVar(huff_tree, temp);
end
% create a Huffman tree from the reduced number of free nodes
huff_tree = create_tree(huff_tree, n_ary, variance);
return;

%--------------------------------------------------------------------------
%% This function will insert a node in the sorted list such that the
% resulting list will be sorted (ascending). If there exists node with the
% same probability as the new node, the new node  is placed after these
% same value nodes.
function huff_tree = insertMaxVar(huff_tree, newNode)
sortedOn = [huff_tree.probability];
i = 1;
while i <= length(huff_tree) && ...
        newNode.probability > huff_tree(i).probability 
    i = i+1;
end
huff_tree = [huff_tree(1:i-1) newNode huff_tree(i:end)];

%--------------------------------------------------------------------------
%% This function will insert a node in the sorted list such that the
% resulting list will be sorted (ascending). If there exist nodes with the
% same probability as the new node, the new node  is placed before these
% same value nodes.
function huff_tree = insertMinVar(huff_tree, newNode)
sortedOn = [huff_tree.probability];
i = 1;
while i <= length(huff_tree) && ...
        newNode.probability >= huff_tree(i).probability
    i = i+1;
end
huff_tree = [huff_tree(1:i-1) newNode huff_tree(i:end)];


%--------------------------------------------------------------------------
%% This function does a pre-order traversal of the tree to create the codes
% for each leaf node. This is a recursive function
function [huff_tree,dict,total_wted_len] = create_dict(huff_tree,dict,total_wted_len, n_ary)
% Check if the current node is a leaf node If it is, then add the signal on
% this node and its corresponding code to the dictionary global n_ary
if( length(huff_tree.child) == 0 )
    dict{end+1,1} = huff_tree.signal;
    dict{end, 2} = huff_tree.code;
    dict{end, 3} = length(huff_tree.code);
	dict{end, 4} = huff_tree.origOrder;
    total_wted_len = total_wted_len + length(huff_tree.code)*huff_tree.probability;
    return;
end
num_childrens = length(huff_tree.child);
for i = 1:num_childrens
    huff_tree.child{i}.code = [huff_tree(end).code, (num_childrens-i)];
    [huff_tree.child{i}, dict, total_wted_len] = ...
        create_dict(huff_tree.child{i}, dict, total_wted_len, n_ary);
end