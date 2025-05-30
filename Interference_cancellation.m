function rx_data = Interference_cancellation(Y,hs,alpha,cp_len,occupied_subcarriers)
 %INTERFERENCE_CANCELLATION Projects the received signal onto a different subspace
 %and obtains the projected received signal 
 %proj_vec = [1; -alpha];
 %y_proj = proj_vec' * Y;
 % rx_dec_data = y_proj/(hj(2)*hs(1)-hj(1)*hs(2));
 rx_dec_data = (Y(1,:) - alpha*Y(2,:))/(hs(1) - alpha*hs(2));
 rx_no_cp = rx_dec_data(cp_len+1:end);
 rx_data = fft(rx_no_cp, occupied_subcarriers);
end

