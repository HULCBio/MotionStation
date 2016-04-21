function st = getallfields(opts)
% GETALLFIELDS Return struct of all fields of a fitoptions object.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:41:09 $

st = get(opts);
st.Jacobian = get(opts,'Jacobian'); % Hidden field: must get explicitly
