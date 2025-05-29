function tx_ofdm = transmitter(N_subcarriers,occupied_subcarriers,mod_order,cp_len,data_bits)
%TRANSMITTER Generates random bits that will be sent via BPSK modulated
%signals.

    % BPSK: 1 bit per symbol
    mod_data = pskmod(data_bits, mod_order);            % BPSK modulation
    
    t = zeros(N_subcarriers, 1);                        %Conversion to a vector of length
    t(1:occupied_subcarriers) = mod_data;               % = N_subcarriers

    time_data = ifft(t,N_subcarriers);
    tx_ofdm = [time_data(end - cp_len + 1 : end); time_data].';
end

