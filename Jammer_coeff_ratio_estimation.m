function alpha = Jammer_coeff_ratio_estimation(hs,pilot,mixed_signal)
%JAMMER_COEFF_ESTIMATION Estimates jammer coeff ratio.
    jam_signal = mixed_signal - hs*pilot;
    alpha = jam_signal(1, :) ./ jam_signal(2, :); 
end

