function rx_data = Interference_cancellation(Y,hs_est,alpha,cp_len,occupied_subcarriers)
 %INTERFERENCE_CANCELLATION Projects the received signal onto a different subspace
 %and obtains the projected received signal 
 % rx_dec_data = zeros(1,cp_len+occupied_subcarriers);
 Y = fft(Y, N_subcarriers);
 rx_dec_data = (Y(1,:) - alpha.*Y(2,:))./(hs_est(1,:) - alpha.*hs_est(2,:));
 rx_no_cp = rx_dec_data(cp_len+1:end);
 rx_data = rx_no_cp;
end

