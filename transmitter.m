function tx_ofdm = transmitter(occupied_subcarriers,mod_order,cp_len,data_bits)
%TRANSMITTER Prepares Data Transmission by implementing BPSK modulation
% BPSK: 1 bit per symbol
    tx_power = 1;
    mod_data = sqrt(tx_power)*pskmod(data_bits, mod_order);            % BPSK modulation
    time_data = ifft(mod_data,occupied_subcarriers);
    tx_ofdm = [time_data(end - cp_len + 1 : end),time_data];

end

