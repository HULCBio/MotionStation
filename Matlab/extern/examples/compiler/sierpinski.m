function [x, y] = sierpinski(iterations, draw)
% SIERPINSKI Calculate (optionally draw) the points in Sierpinski's triangle

    % Three points defining a nice wide triangle
    points = [0.5 0.9 ; 0.1 0.1 ; 0.9 0.1];

    % Select an initial point
    current = rand(1, 2);

    % Create a figure window
    if (draw == true)
        f = figure;
        hold on;
    end

    % Pre-allocate space for the results, to improve performance
    x = zeros(1,iterations);
    y = zeros(1,iterations);

    % Iterate
    for i = 1:iterations

        % Select point at random
        index = floor(rand * 3) + 1;

        % Calculate midpoint between current point and random point
        current(1) = (current(1) + points(index, 1)) / 2;
        current(2) = (current(2) + points(index, 2)) / 2;

        % Plot that point
        if draw, line(current(1),current(2));, end
	x(i) = current(1);
        y(i) = current(2);

    end

    if (draw)
        drawnow;
        input('Press any key to continue.');
        close(f);
    end
    
