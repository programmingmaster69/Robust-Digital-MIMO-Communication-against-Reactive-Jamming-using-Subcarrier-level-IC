function hs_est = sender_coeff_estimator(symbol_n, pilot,alpha, y, sender_coeff_switch, prev_hs)
%SENDER_COEFF_ESTIMATOR Estimates sender channel coefficients from known
%pilot data.
    if symbol_n == 1
        hs_est = [y(1,:)./pilot ; y(2,:)./pilot];
    elseif sender_coeff_switch == 0
        hs_est(1,:)  = (y(1,:) - alpha.*y(2,:))./pilot + alpha.*prev_hs(2,:);
    elseif sender_coeff_switch == 1
        hs_est(2,:)  = alpha.*prev_hs(1,:) -(y(1,:) - alpha.*y(2,:))./pilot;
    end
    
end

