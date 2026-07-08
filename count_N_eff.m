%  Безопасно вычисляет число мод N_eff

function N_eff = count_N_eff(s)
    s = s(:);
    s = s(isfinite(s) & s > 0);

    if isempty(s)
        N_eff = NaN;
        return;
    end

    theta = s ./ sum(s);
    N_eff = exp(-sum(theta .* log(theta)));
end