jam_power = 0.4; 
N_packets = 500;
mod_order = 2;
occupied_subcarriers = 48;
N_subcarriers = 64;
cp_len = 16;
n_trials = 10;
for run = 1:n_trials
    success=0;
    for packets = 1: N_packets
        %Channel Coeffs
        hs = (randn(2,1) + 1i*randn(2,1)) / sqrt(2); % ------ sender coeff
        hj = (randn(2,1) + 1i*randn(2,1)) / sqrt(2); % ------ jammer coeff

        %Transmitter config
        data_bits = randi([0 1], occupied_subcarriers, 1);
        t = transmitter(N_subcarriers, occupied_subcarriers, mod_order,cp_len,data_bits);

        %Jammer config
        j = jammer(N_subcarriers,cp_len,jam_power);

        %Receiver config
        y = receiver(hs,hj,t,j);
        rx_data = Interference_cancellation(y,hs,hj,cp_len,N_subcarriers,occupied_subcarriers);
        rx_bits = pskdemod(rx_data, mod_order);
        if all(rx_bits.' == data_bits)
            success = success + 1;
        end
    end
end