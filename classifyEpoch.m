function[C] = classifyEpoch(data, clsfr)
    [f,~,~,~] = apply_ersp_clsfr(data,clsfr);
    for i=1:size(clsfr.spMx,2)
        if (clsfr.spMx(i) == -1)
            f(f < 0) = clsfr.spKey(i);
        elseif (clsfr.spMx(i) == 1)
            f(f >= 0) = clsfr.spKey(i);
        else
            'error!'
        end
    end
    C = f;
end