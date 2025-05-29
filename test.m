% Simulation Configuration
    N_subcarriers = 512;
    occupied_subcarriers = 200;
    cp_len = 128;
    mod_order = 2; % BPSK
    n_packets = 5000;
    repeats = 10;
    jam_power = 2;

    pdr_results = zeros(repeats,1);

    for run = 1:repeats
        success = 0;

        for pkt = 1:n_packets
            % ------------------ Transmitter ------------------
            data_bits = randi([0 1], occupied_subcarriers, 1);  % BPSK: 1 bit per symbol
            mod_data = pskmod(data_bits, mod_order);            % BPSK modulation

            % Frequency-domain OFDM symbol
            freq_data = zeros(N_subcarriers, 1);
            freq_data(1:occupied_subcarriers) = mod_data;

            % Time-domain OFDM with cyclic prefix
            time_data = ifft(freq_data);
            tx_ofdm = [time_data(end - cp_len + 1 : end); time_data];

            % ------------------ Jammer Signal ------------------
            jam_bits = randi([0 1], occupied_subcarriers, 1);
            jam_mod = pskmod(jam_bits, mod_order);
            jam_freq = zeros(N_subcarriers, 1);
            jam_freq(1:occupied_subcarriers) = jam_mod;
            jam_time = ifft(jam_freq);
            jam_ofdm = [jam_time(end - cp_len + 1 : end); jam_time];
            jam_ofdm = sqrt(jam_power) * jam_ofdm;

            % ------------------ Channel Effects ------------------
            hs = (randn(2,1) + 1i*randn(2,1)) / sqrt(2);  % Sender channels
            hj = (randn(2,1) + 1i*randn(2,1)) / sqrt(2);  % Jammer channels

            rx1 = hs(1)*tx_ofdm + hj(1)*jam_ofdm;
            rx2 = hs(2)*tx_ofdm + hj(2)*jam_ofdm;
            Y = [rx1, rx2].';

            % ------------------ Interference Cancellation ------------------
            alpha = hj(2) / hj(1);
            proj_vec = [1; -alpha];
            y_proj = proj_vec.' * Y;

            % Remove CP and apply FFT
            y_no_cp = y_proj(cp_len+1:end);
            rx_fft = fft(y_no_cp, N_subcarriers);
            rx_data = rx_fft(1:occupied_subcarriers);

            % Demodulate and compare
            rx_bits = pskdemod(rx_data, mod_order);
            if all(rx_bits == data_bits)
                success = success + 1;
            end
        end

        % PDR for this run
        pdr = success / n_packets;
        pdr_results(run) = pdr;
        fprintf("Run %d: PDR = %.3f\n", run, pdr);
    end

    % Average PDR across all runs
    fprintf("Average PDR across %d runs: %.3f\n", repeats, mean(pdr_results));