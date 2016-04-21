function disp(se)
%DISP Display method for structuring element objects.
%   DISP(SE) prints a description of the structuring element SE to the
%   command window.
%
%   See also STREL, STREL/DISPLAY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.6.6.1 $  $Date: 2003/01/26 05:57:25 $

if length(se) ~= 1
    % STREL array; should work for empty case as well
    s = size(se);
    str = sprintf('%dx',s);
    str(end) = [];
    fprintf('%s array of STREL objects\n', str);
else
    % Single STREL object
    nhood = getnhood(se);
    num_neighbors = sum(nhood(:) ~= 0);
    
    flat_strel = isflat(se);
    if flat_strel
        first_word = 'Flat';
    else
        first_word = 'Nonflat';
    end
    
    if num_neighbors > 1 | num_neighbors == 0
        plural_suffix = 's';
    else
        plural_suffix = '';
    end
    fprintf('%s STREL object containing %d neighbor%s.\n', ...
            first_word, num_neighbors, plural_suffix);
    
    sequence = getsequence(se);
    num_strels = length(sequence);
    if num_strels > 1
        num_decomposed_neighbors = 0;
        for k = 1:num_strels
            nhood_k = getnhood(sequence(k));
            num_decomposed_neighbors = num_decomposed_neighbors + ...
                sum(nhood_k(:) ~= 0);
        end
        fprintf('Decomposition: %d STREL objects containing a total of %d neighbors\n',...
                num_strels, num_decomposed_neighbors);
    end
    
    if num_neighbors > 0
        fprintf('\nNeighborhood:\n')
        disp(getnhood(se))
        
        if ~flat_strel
            fprintf('\nHeight:\n')
            disp(getheight(se))
        end
    end
end
