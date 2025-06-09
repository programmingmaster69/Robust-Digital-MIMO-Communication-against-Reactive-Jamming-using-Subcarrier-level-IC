function alpha = Jammer_coeff_ratio_estimation(hs,pilot,y)
%JAMMER_COEFF_ESTIMATION Estimates jammer coeff ratio.
    alpha = (y(1,:) - hs(1,:) .* pilot) ./ (y(2,:) - hs(2,:) .* pilot); 
end

