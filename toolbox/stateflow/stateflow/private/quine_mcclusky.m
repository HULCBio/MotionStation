function compactExps = Quine_McClusky(rawExps, overlap)
%  Quine-McClusky algorithm for minimizing Boolean expressions (fixed bit sequence)
%  input: rawExps  the raw, unsimplified expressions, as in char array
%         overlap  allow overlap among compact expressions
%  output: compactExps   the simplified expressions, as in char array
%                        compact expressions are prime implicants
%  JIT: Code optimized for JITability
%  Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.2.4.1 $  $Date: 2004/04/15 00:59:03 $

[m n] = size(rawExps);

% Divide input rawExps to groups depending number of 1's
group = cell(n+1, 1); % none 1's to all 1's, max n+1 groups
for i = 1:m
    onesCount = 0; % count number of ones
    for j = 1:n
        if rawExps(i, j) == '1'
            onesCount = onesCount + 1;
        end
    end

    group{onesCount+1}(end+1, :) = rawExps(i, :);
end

for i = 1:n+1
    % make sure all expressions are unique
    group{i} = unique(group{i}, 'rows');
end

% Merge groups and take out prime implicants
compactExps = char([]); % init
reduced = 1; % is expressions reduced?

while reduced % until exps cannot be reduced more
    reduced = 0;
    newGroup = cell(n+1, 1); % group to cache up merged exps
    g2Mark = zeros(size(group{1}, 1), 1);
    
    for i = 1:n
        g1 = group{i};
        g2 = group{i+1};
        
        g1Mark = g2Mark; % g1Mark, g2Mark is an exp used in merge
        g2Mark = zeros(size(g2,1), 1);
        
        for i1 = 1:size(g1, 1)
            if ~overlap && g1Mark(i1)
                % Don't merge already merged expression to assure no overlap
                continue;
            end
            
            for i2 = 1:size(g2, 1)
                if ~overlap && (g1Mark(i1) || g2Mark(i2))
                    % Don't merge already merged expression to assure no overlap
                    continue;
                end
                
                posDiff = 0; % The position for differ bit
                for j = 1:n
                    if g1(i1, j) ~= g2(i2, j);
                        if posDiff
                            % More than two bits differ, cannot merge
                            posDiff = 0;
                            break;
                        else
                            posDiff = j;
                        end
                    end
                end
                
                % To reduce if two exps has only 1 bit differ
                if posDiff
                    reduced = 1;
                    
                    mergedExp = g1(i1, :);
                    mergedExp(posDiff) = '-';

                    newGroup{i}(end+1, :) = mergedExp;
                    
                    g1Mark(i1) = 1;
                    g2Mark(i2) = 1;
                end
            end
            
            if ~g1Mark(i1) 
                % exp is prime implicant
                compactExps(end+1, :) = g1(i1, :);
            end
        end
    end
    
    % Include prime implicant from last group, all '1's or all 'T's
    if ~isempty(g2) && ~g2Mark(1) % Can only have 1 minterm in last group, which has all '1's
        compactExps(end+1, :) = g2(1, :);
    end
    
    for i = 1:n+1
        % make sure exps are unique
        newGroup{i} = unique(newGroup{i}, 'rows');
    end
    
    group = newGroup;
end
