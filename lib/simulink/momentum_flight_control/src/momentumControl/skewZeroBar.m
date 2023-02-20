function X = skewZeroBar(x)

    % skewZeroBar
    %
    % used in the flying controller.
    %
    X = [zeros(3); wbc.skew(x)];
end

