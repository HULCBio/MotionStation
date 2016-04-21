function dummy = copy_structure(st,resp)
%   Private. Copies over ST properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.


% public properties
resp.name                   = st.name;
resp.address                = st.address;
resp.storageunitspervalue   = st.storageunitspervalue; % warning: position of superval is critical;
resp.size                   = st.size;                 % it must come before size
resp.numberofstorageunits   = st.numberofstorageunits;
resp.arrayorder             = st.arrayorder;
resp.link                   = st.link;
resp.member                 = st.member;
resp.membname               = st.membname;

% private properties

resp.memboffset             = st.memboffset;
resp.membnumber             = st.membnumber;
resp.pregetlisteners        = st.pregetlisteners;

% [EOF] copy_structure.m
