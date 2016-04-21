function javaInteger = getCount(this)

% Copyright 2003 The MathWorks, Inc.

% return number of items in the list as a java Integer.

javaInteger = java.lang.Integer(length(this.ListData));