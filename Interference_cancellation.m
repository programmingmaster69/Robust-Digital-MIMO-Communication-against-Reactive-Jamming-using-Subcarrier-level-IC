function rx_data = Interference_cancellation(Y,hs,alpha,cp_len,occupied_subcarriers)
 %INTERFERENCE_CANCELLATION Projects the received signal onto a different subspace
 %and obtains the projected received signal 
 rx_dec_data = zeros(1,cp_len+occupied_subcarriers);
 for i = 1:64
    rx_dec_data(i) = (Y(1,i) - alpha(i)*Y(2,i))/(hs(1) - alpha(i)*hs(2));
 end
 rx_no_cp = rx_dec_data(cp_len+1:end);
 rx_data = fft(rx_no_cp, occupied_subcarriers);
end

