function X = skewBar(x)

    % skewBar
    %
    % used in the flying controller.
    %
    X = [eye(3); wbc.skew(x)];
end

