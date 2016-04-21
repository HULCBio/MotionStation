function out = shuffle(in)

% Copyright 2002 The MathWorks, Inc.

    out = in;
    out(:) = [];

    dims = size(in);

    while ~isempty(in)
        element = ceil(rand*length(in));
        out(end+1) = in(element);
        in(element) = [];
    end

    out = reshape(out, dims);
    