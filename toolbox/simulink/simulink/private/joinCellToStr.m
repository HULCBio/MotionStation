function jointStr = joinCellToStr(inpCell,joinExpr)
% This function joins strings in cell array inpCell into a single
% string jointStr using the string joinExpr.

% Copyright 2004 The MathWorks, Inc.

jointStr = '';

if isempty(inpCell)
  return;
end

if ischar(inpCell)
  jointStr = inpCell;
elseif iscell(inpCell)
  jointStr  = char(inpCell{1});
  for idx   = 2:length(inpCell)
    jointStr= [jointStr joinExpr char(inpCell{idx})];
  end
end
