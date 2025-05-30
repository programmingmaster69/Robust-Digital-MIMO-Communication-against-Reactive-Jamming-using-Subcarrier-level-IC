jam_power = 0; 
N_packets = 500;
mod_order = 2;
occupied_subcarriers = 48;
N_subcarriers = 64;
cp_len = 16;
n_trials = 10;
pdr_results = zeros(n_trials,1);
for run = 1:n_trials
    success=0;
    for packets = 1: N_packets
        %Channel Coeffs -- Jammer coeffs not known to us
        hs = (randn(2,1) + 1i*randn(2,1)) / sqrt(2); % ------ sender coeff
        hj = (randn(2,1) + 1i*randn(2,1)) / sqrt(2); % ------ jammer coeff

        %Jammer config
        j = jammer(N_subcarriers,cp_len,jam_power);

        %Pilot Sending:
        pilot = zeros(1,N_subcarriers+cp_len);
        pilot(2:15) = 1;
        mixed_signal = receiver(hs,hj,pilot,j,N_subcarriers,cp_len);

        %Transmitter config
        data_bits = randi([0 1], occupied_subcarriers, 1);
        t = transmitter(N_subcarriers, occupied_subcarriers, mod_order,cp_len,data_bits);

        

        %Receiver config
        y = receiver(hs,hj,t,j,N_subcarriers,cp_len);
        %Jammer coeff ratio
        alpha = Jammer_coeff_ratio_estimation(hs,pilot,mixed_signal);
        rx_data = Interference_cancellation(y,hs,alpha,cp_len,N_subcarriers,occupied_subcarriers);
        rx_bits = pskdemod(rx_data, mod_order);
        if all(rx_bits.' == data_bits)
            success = success + 1;
        end
    end
    pdr = success / N_packets;
    pdr_results(run) = pdr;
    fprintf("Run %d: PDR = %.2f%%\n", run, pdr * 100);
end
fprintf("Average PDR across %d runs: %.2f%%\n", n_trials, mean(pdr_results)*100);