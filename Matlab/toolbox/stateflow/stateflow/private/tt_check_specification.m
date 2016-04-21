function [over, under, status] = tt_check_specification(ttx)
%TT_CHECK_SPECIFICATION Checks a truth table for practical completeness
%
%  Usage:
%
%   [OVER, UNDER] = TT_CHECK_SPECIFICATION(TABLE)
%
%  TABLE is encoded as a matrix of TRUE, FALSE, and 
%  DON'T CARE values ('T', 'F', '-') in an array of (1, 0, -1)
%  values where each column makes up one case combination, e.g.,
%  the table of T F - is coded as:
%
%     T F - -             1  0 -1 -1
%     F F T -   code as   0  0  1 -1
%     F F F T             0  0  0  1
%
%  The above has 4 cases that expand via the don't care entries
%  into 2^rows = 2^3 = 8 entries, the full truth table. 
%
%  OVER is an m-by-n array where row values [c1, c2] indicate
%  column indices such that column c1 is already specified by 
%  column(s) c2.  c2 can be a row vector on its own.
%
%  UNDER return values represent the missing logic cases.
%
%  Refer to the "Using Stateflow" manual for a more detailed discussion
%  of the truth table specification analysis performed by this function.
%

%  roa 30-JAN-2002; rewritten, roa 04-SEP-2002

% Copyright 2002 The MathWorks, Inc.
%  $Revision: 1.3.4.2 $ $Date: 2004/04/15 01:01:18 $
%
%

% --- Truth table legal values

dcval = (-1); % code for don't care

% --- Constants

rowLimit = 20;  % 20 rows can cause O(2^20) evaluations and use 
                % 2 MB RAM per copy for uint16 breadcrumbs.
                % Limit applies to non-sparse portion of table only.

algError_msg = sprintf(['Truth Table specification algorithm error. ' ...
                        'Please contact MathWorks technical support']);


% --- Check for valid input form for truth table: 
%     numeric array that contains only 1, 0, and -1.

over = {};
under = [];
status = {};  % list of messages to optionally use

if ~isnumeric(ttx) || (length(find(abs(double(int32(ttx))) > 1)) > 1),
  msg = sprintf('One or more truth table data elements are invalid.')
  status{end+1} = msg;
  return;
end

% --- Get size of table to analyze and get a canonical representation

[nr, ncFull] = size(ttx);
tt = double(int32(ttx));  % be doubly sure values are integers

% --- Detect invalid use of default case (allowed only in last column)

for k=1:(ncFull-1),
  if sum(find(tt(:,k) == dcval)) == sum(1:nr),
    msg = sprintf(['Truth table contains invalid use of ' ...
        'default column in column D%d; a default column is ' ...
        'only permitted as the last column in the table.'], k);
    status{end+1} = msg;
    return;
  end
end


% --- Detect and set up for valid use of the default case

if sum(find(tt(:,end) == dcval)) == sum(1:nr),
  % last column is all don't cares
  nc = ncFull - 1;
  hasDefaultCol = true;
else
  nc = ncFull;
  hasDefaultCol = false;
end


%
% --- Eliminate reachable, detachable sparse items
%
%     Sparse entries are detected as follows:
%
%        1 2 3 4 5 6
%        F T - - - -
%        - - F - T -
%        - - - F - -
%        - T - - - -
%        - F - - - -
%
%     If they are reachable, Columns 3 and 5 make a "sparse pair" and 
%     are eliminated together, but note that column 6 is unreachable 
%     because 3 and 5 together block out everything else.
%
%     Column 4 is sparse on its own and is eliminated because of the 
%     presence of the default column at the end.  So for 5 rows, the
%     sparseness elimination reduces the analysis from 6 to 3 columns
%     (elim. cols 3,4,5) and from 5 to 3 rows (elim rows 2 and 3).
%     The default column does not need to be analyzed, its behavior is 
%     known a priori.
%
%     Sparse Rule 1:  if a column is sparse and has a conjugate sparse
%                     column elsewhere, eliminate both from the analysis.
%
%     Sparse Rule 2:  if a column contains only 1 value that is a T or
%                     an F and all the other entries are don't care AND
%                     no other column has a T or F entry for that row,
%                     the column is sparse and can be removed from the 
%                     analysis.  If there is no default column and Rule
%                     1 doesn't apply, also log the missing case.
%
%     Sparse Rule 3:  if there are duplicate entries of a sparse
%                     column, the duplicate columns overspecify the
%                     table.  Note the overspecification, then 
%                     remove all of them.
%
%
%     In order for final reporting to make sense, the over/under reporting
%     of the reduced matrix is adjusted to account for the removed columns.
%

tts = tt;
removedCols = zeros(1,nc);
removedRows = zeros(1,nr);

for m=1:nc,
  if removedCols(m) == m, continue; end % skip this col if already eliminated
  
  ridx  =        find(tts(:,m) >= 0);   % find T or F entries
  numdc = length(find(tts(:,m) <  0));  % number of don't care
                                        % entries
  
  num_NonSparseColumns_UsingThisRow = 0;
  sparse_companion_col = [];
  
  if length(ridx) == 1 && (numdc > 0),
    %
    % Find non-sparse columns that have a T or F at ridx and
    % see if there are other similar column companions.
    %
    cidx = find(tts(ridx,:) >= 0);
    numCIdx = length(cidx);
    sparse_companion_col = zeros(1,numCIdx);
    if numCIdx > 1,
      %
      % Other columns care about this row, are they sparse too?
      %
      for k=1:numCIdx,
        if cidx(k) ~= m,
          companion_ridx  =        find(tts(:,cidx(k)) >= 0);
          companion_numdc = length(find(tts(:,cidx(k)) <  0));
          
          if length(companion_ridx) == 1 && (companion_numdc) > 0
            %
            % Found another column with a sparseness pattern like
            % this one's pattern (m-th col).
            %
            sparse_companion_col(k) = cidx(k);
          else
            %
            % Found a non-sparse column with a T or F at ridx, the 
            % m-th column is therefore not sparse.
            %
            num_NonSparseColumns_UsingThisRow = num_NonSparseColumns_UsingThisRow + 1;
          end
        end
      end
    end
    sparse_companion_col = sparse_companion_col(sparse_companion_col > 0);    
  end
  
  if length(ridx) == 1 && (numdc > 0) && num_NonSparseColumns_UsingThisRow == 0,
    %
    % This column is sparse, but it may have duplicates or conjugates.
    %
    % NOTE: this algorithm can be extended to allow multiple entries
    %       of T or F in a column to still be set as a sparse column,
    %       as long as no other column cares about this row, or at most
    %       one other column cares about this column.
    %
    setIdx = find(tts(ridx,:) >= 0);  % other sparse columns with T or F
                                      % entries in this row
    if length(sparse_companion_col) == 0,
      %
      % Yes, this column is the one column that is all don't
      % cares except the ridx-th row, and no other column cares
      % about the value of this row.  It is really "sparse".
      %
      removedRows(ridx) = ridx;
      removedCols(m) = m;
      
    else
        
      mIdx    = find(setIdx == m);
      notMIdx = find(setIdx ~= m);
      ss      = sort(setIdx);
      
      %
      % Check to see if the companion column(s) are the conjugate
      % of this one or duplicates.  Remove all, mark as overspecifications.
      %
      scc = sparse_companion_col;
      for k = 1:length(scc),
        compIdx = scc(k);
        removedCols(ss(mIdx)) = ss(mIdx);
        if logical(tts(ridx, scc(k))) == ~logical(tts(ridx,m)),
          %
          % Conjugate sparse column or dup conj sparse col, nothing 
          % beyond k-th one is reachable.
          %
          removedCols(scc(k):end) = scc(k):nc;
          for kk=(scc(k)+1):ncFull,
            over{end+1} = [ kk, ss(mIdx), scc(k) ];
          end
        else
          %
          % Duplicate sparse columns, remove both, mark k-th as
          % overspecified.
          %
          removedCols(scc(k)) = scc(k);
          over{end+1} = [ scc(k), ss(mIdx) ];
        end
        removedRows(ridx) = ridx;
      end
    end
  end
end

%
% --- Remove sparse columns from the table so we can analyze the remaining
%     table more efficiently.
%

keepRows = find(removedRows == 0);
keepCols = find(removedCols == 0);
tt = tt(keepRows,keepCols);
[nrs,ncs] = size(tt);

%
% --- Check for over-specification.
%
%     Compare each column to all columns to the right of itself.  If 
%     either a simple match is found or at least one column is a don't 
%     care on every row, then it is a matching column and is 
%     overspecified.  
%
%     In the case of the last column being the default case (all don't 
%     care values), it is only an overspecification condition if
%     the rest of the table constitutes a full specification.
%

if nrs == 0 && isempty(tt) && isempty(over),
  if  ~hasDefaultCol && length(keepCols) <= 1,
    if length(keepCols) == 1,
      % 
      % Degenerate case of all sparse rows, no overspecifications,
      % and no default column: there is exactly one possible case left,
      % is it correct, or not?
      %
      % Get canonical index of remaining case, if it exists
      %
      canonicalIdx = bin2dec(char(tts(:,keepCols)'+'0'));
      %
      % Get canonical index of the one possibly OK set of column values
      %
      OKIdx = 0;
      for k=removedCols(removedCols > 0),
        careRow = find(tts(:,k) >= 0);
        for crIdx=1:length(careRow),
          OKIdx = bitset(OKIdx, careRow(crIdx), double(~tts(careRow(crIdx),k)));
        end
      end
      %
      % Compare column canonical index to the OK index value.
      %
      if canonicalIdx == OKIdx,
        % Exactly specified
        under = [];
      else
        over{end+1} = [ keepCols unique(removedCols) ];
        under = OKIdx;
      end
      %
      % Whether or not the indices match, there is no need to go
      % through the breadcrumb search at this point.
      %
      breadcrumbs = [];
      nr = 0;
      nc = 0;
    elseif length(keepCols) == 0,
      %
      % Table is missing the one possible value left (degenerate)
      %
      OKIdx = 0;
      for k=removedCols(removedCols > 0),
        careRow = find(tts(:,k) >= 0);
        for crIdx=1:length(careRow),
          OKIdx = bitset(OKIdx, careRow(crIdx), ~tts(careRow(crIdx),k));
        end
      end
      nr = 0;
      nc = 0;
      under = OKIdx;
    else
      %
      % Being here should be impossible.
      %
      status{end+1} = algError_msg;
      return;
    end
  else
    %
    % Table has zero rows left and zero or one columns (meaningless).
    %   ~ OR ~
    % Table has a default column.
    %
    if hasDefaultCol,
      % 
      % Need to know if the table is fully specified or if there
      % is the one remaining case that the default case could handle.
      %
      if length(keepCols) == 0,
        %
        % Default case will handle the one remaining case.
        % This could be an additional bit of diagnostic info.
        %
        OKIdx = 0;
        for k=removedCols(removedCols > 0),
          careRow = find(tts(:,k) >= 0);
          for crIdx=1:length(careRow),
            OKIdx = bitset(OKIdx, careRow(crIdx), double(~tts(careRow(crIdx),k)));
          end
        end
        under = OKIdx;
      end
      %
      % Basically done, no need for breadcrumb search
      %
      nr = 0;
      nc = 0;
      breadcrumbs = [];
    else
      %
      % Being here should be impossible according to the 
      % definition of sparseness
      %
      status{end+1} = algError_msg;
      return;
    end
  end
else
  %
  % Normal case (possibly sparsified) that fits within design constraints
  %
  nr = nrs;
  nc = ncs;
  breadcrumbs = repmat(uint8(0), pow2(nr), 1);
  under = [];
end

%
% ==== Size check on remaining table
%
% Ensure that the possibly reduced table is smaller than the maximum
% that a "present day" (circa 2002) computer is likely to be able to
% handle.  The problems are exponential time in the below algorithm and 
% exponential memory consumption on the order of the remaining number 
% of rows.
% 


if nr > rowLimit,
  %
  % Too big to practically analyze
  % Bytes consumed also depends on sizeof for the breadcrumbs datatype
  %
  sizeofEntry = 1;
  msg = sprintf(['Table is too large to analyze practically, limit is set to ', ...
      '%d rows or fewer (Note: 2^%d => %d MB RAM)'], ...
    rowLimit, rowLimit, sizeofEntry * (2^rowLimit)/(2^20));
  status{end+1} = msg;
  return;
end



% =============================
% 
% Use a breadcrumb algorithm to check overspecification. Directly calculate
% index into canonical array (0000 first, 1111 last).  No need to consider
% sparse columns because they do no affect reachability of the remaining 
% table.  That is why the sparse columns were removable.
% 


for m=1:nc   % Proceed column-wise from left to right in table
  newOver = [];
  %
  % --- Check to see if this column gets over-specified by a column
  %     to its right.
  %
  if m < nc,
    for k = (m+1):nc,
      %
      % --- Can the k-th column be morphed to look like column m?  If true, 
      %     then column k contains >= 1 duplicates of column m contents and
      %     column k overlaps column m.
      %
      overlap = true;  % guilty until proven innocent
      for j=1:nr,
        % 
        % A match for the j-th condition occurs if: 
        %      col m and col k items are the same
        %   OR col m item is a don't care
        %   OR col k item is a don't care
        %
        if ~(tt(j,m) == tt(j,k) || tt(j,m) == dcval || tt(j,k) == dcval),
          % Column k does not overlap column m in any way
          overlap = false;
          break; % leave j loop now
        end
      end
      
      if overlap == true,
        %
        % Determine if the overlap is an over-specification
        %
        isoverspec = false; % innocent until proven guilty here
        %
        % Handle Rule b:
        %
        % "A column expansion that overlaps a column specified to its left
        % should be excluded from the fully expanded set of columns without
        % the condition set being considered over-specified."
        %
        % First part of Rule b handling:
        %
        % => If columns are exact duplicates, mark as an over-specification
        %    because column k's condition sets will never execute.
        %
        if isequal(tt(:,m), tt(:,k)),
          isoverspec = true;
        end
        %
        % Handle Rule c:
        %
        % "A fully specified column that overlaps an expanded column to its
        % left is considered overspecified."
        %
        % => If there are zero don't cares in column k then this 
        %    condition set is unreachable and therefore is an 
        %    over-specification of column m.
        %
        if isempty(find(tt(:,k) == dcval)),
          isoverspec = true;
        end
        
        % Log any overspecified items
        if isoverspec == true,
          newOver = [k, m]; % column k is unreachable
        end
      end   % overlap to the right is true
    end     % k loop looking to the right
  end       % m < nc, "if not the last column"
  %
  % More on Rule b:
  %
  % => If column m is different from columns to its left and both columns 
  %    have don't cares, do further analysis of all columns to the 
  %    left of m to determine if column m is reachable, i.e., if all 
  %    the columns to the left of m specify all of m's expanded 
  %    conditions, then column m can never execute and is an 
  %    over-specification.
  %
  % === First, find space swept by columns up to and including column m. 
  %     Each pass of the m loop, add the effect of the column m to the
  %     set of reachable conditions by marking the breadcrumbs array.
  %
  tcol = tt(:, m);
  dcidx = find(tcol == (-1));
  
  conditionSetReachable = false; % Set true if column >=1 reachable conditions
  overspecs = zeros(nc,1);
  
  if isempty(dcidx),
    %
    % Mark the canonical position of this fully specified column.
    % 
    ii = sum(  double(tcol) .* pow2( (0:(nr-1))' )  ) + 1;
    if (breadcrumbs(ii) == 0),
      breadcrumbs(ii) = m;
    end
    % if over-specified, it is already marked.
    %
  else
    %
    % --- Expand don't cares on this expandable column.
    %
    %     Record the space that this expanding column sweeps out.
    %     Directly mark the canonical positions of each fully 
    %     specified column.
    %     (0000 first ---> 1111 last).
    %
    caresOffset = 0;
    careSet = tcol;
    careSet(dcidx) = 0;
    incr = 1;
    for i = 1:nr,
      caresOffset = caresOffset + incr * careSet(i);
      incr = incr * 2;
    end
    ndc           = length(dcidx);
    ndcCount      = 2^ndc;
    dontCaresMask = pow2(dcidx(end:-1:1) - 1)';
    idxBitMask    = pow2(1-ndc:0);
    
    % Mark all reached items
    for i = 1:ndcCount,
      %
      %      ==== PERFORMANCE-CRITICAL LOOP ====
      %
      % The following 3 lines will JIT, but use doubles
      %
      ibits = rem(floor(i * idxBitMask), 2);      % from dec2bin
      dontCaresIdx = sum(ibits .* dontCaresMask); % convert to index
      ii = caresOffset + dontCaresIdx + 1;        % canonical position
      if (breadcrumbs(ii) == 0),
        breadcrumbs(ii) = m;
        conditionSetReachable = true; % at least one condition set is reachable
      else
        overspecs(breadcrumbs(ii)) = breadcrumbs(ii);
      end
    end
    % 
    % === Finish "More on Rule b"; do second part:
    %
    if ~conditionSetReachable
      newOver = [m, find(overspecs > 0)'];  % strip zeros
    end
  end
  
  %
  % --- add to the overspec list if this column overspecifies the table
  %
  if ~isempty(newOver),
    % do column label fixup on sparse columns
    overspecDeSparsed = keepCols(newOver);
    over{end+1} = overspecDeSparsed;
  end
  
end % m loop of column over-specification analysis


%
% --- Check for under-specification
%

if isempty(under),
  % This find can turn up empty, resulting in empty
  under = find(breadcrumbs == 0) - 1; % -1 to offset the MATLAB start index
  %
  % Fixup the unders to be the full table index to account for sparse table
  % rows:
  %
  % first, shift the bits into place
  sparseUnder = zeros(length(under),1);
  for k=1:length(keepRows),
    sparseUnder = bitor(sparseUnder, bitshift(bitget(under,k),keepRows(k)-1));
  end
  % 
  % second, OR the sparse bits' complement into place
  sparseMask = 0;
  for k=removedCols(removedCols > 0),
    careRow = find(tts(:,k) >= 0);
    for crIdx=1:length(careRow),
      sparseMask = bitset(sparseMask, careRow(crIdx), double(~tts(careRow(crIdx),k)));
    end
  end
  under = bitor(sparseUnder, sparseMask);
end


% --- Handle a properly entered (but perhaps incorrectly specified) 
%     all-don't-care column case.

if hasDefaultCol,
  if isempty(under),
    %
    % Table is already fully specified, the all-don't-care column is now
    % causing an over-specification condition.
    %
    over{end+1} = [ ncFull, 1:(ncFull-1) ];
  else
    under = [];  % handled by default case
  end
end

% --- Clean up: present uniform results by getting rid of duplicates,
%     unreachable overspecifieds, and empties that are not 0x0 in size.

dupOver = logical(zeros(length(over),1));

if ~isempty(over),
  for m=1:length(over),
    for k=(m+1):length(over),
      if k ~= m && dupOver(k) == false,
        if over{m}(1) == over{k}(1),
          combined = union(over{m}(2:end),over{k}(2:end));
          over{m} = [over{m}(1) combined];
          dupOver(k) = true;
        end
      end
    end
  end
  over = over(dupOver == false);
else
  over = {}; % make sure empty over is of dimension 0x0
end

if length(over) > 1,
  %
  % Do not report an overspecified (unreachable) column as
  % a part of a downstream overspecification, it does not
  % enter into the picture.
  %
  for m=2:length(over),
    for k=1:(m-1),
      keepIdx = find(over{m} ~= over{k}(1));
      over{m} = over{m}(keepIdx);
    end
  end
end

if isempty(under),
  under = [];  % make sure empty under is of dimension 0x0
else
  under = unique(under);
end

%[EOF] tt_check_specification.m
