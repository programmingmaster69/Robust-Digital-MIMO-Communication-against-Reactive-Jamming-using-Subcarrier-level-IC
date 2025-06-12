clc
clear all
%Problem - At low jamming powers, alpha estimation is poor.
%==== Defining parameters =====%
N = 10^4; % Total symbols per transmission
Num_scs = 64;
Occupied_scs = 48;
Num_pckts = 500;
N_sym_pckt = 14;
N_fft = Occupied_scs;
cp_len = 16;
num_trails = 100;
Mod_ord = 2;
N_bits_per_symb = Occupied_scs; % for BPSK
noise_power = 0;
tx_amp = 0.5;
jamming_amp = 0:0.1:1;
pilot_pos = [1,5,9,13];
pilot_matrix = ones(Occupied_scs,1);
pilot_matrix(Occupied_scs/2 - 6: Occupied_scs/2 + 6) = -1;
jammer_type = 'Barrage';
%==== MIMO parameters ====%
n_tx = 1;
n_rx = 2;
for iter = 1:num_trails
    
    ip_data = rand(1,N_bits_per_symb*N) > 0.5;
    ip_data = double(ip_data);
    ip_symbols = pskmod(ip_data,Mod_ord);
    parallel_data = reshape(ip_symbols, N_bits_per_symb,[]);
    if strcmp(jammer_type, 'Barrage')
        jammer = barrageJammer('ERP',100, 'SamplesPerFrame',Num_scs);
    end
    for p = 1:Num_pckts
        % == Defining channel per each coherence interval (each packet) ==%
        h_s = (randn(n_rx,n_tx) + 1j *randn(n_rx,n_tx))/sqrt(2);
        h_j =  (randn(n_rx,n_tx) + 1j *randn(n_rx,n_tx))/sqrt(2);
        Hs = zeros(n_rx,N_fft);
        Hj = zeros(n_rx,N_fft);
        for i = 1:n_rx
            Hs(i,:) = sqrt(1/Occupied_scs)*fft(h_s(i), N_fft);
            Hj(i,:) = sqrt(1/Occupied_scs)*fft(h_j(i), N_fft);
        end
        for s = 1:N_sym_pckt
            %=== OFDM transmission starts here ====%
            jammer_signal = jammer().';
            jammer_signal(1:2) = 0;
            if ismember(s,pilot_pos)
                parallel_data(:,(p-1)*(N_sym_pckt)+ s) = pilot_matrix;
            end
            time_data = sqrt(Occupied_scs)*ifft(parallel_data(:,(p-1)*(N_sym_pckt)+ s), N_fft);
            serial_data = time_data.';
            serial_tx_data = [serial_data(end-cp_len+1:end) serial_data]; % after cp addition
            % === computing the received signal at rx antennas
            n = sqrt(noise_power/2)*((randn(n_rx,Num_scs) + 1j *randn(n_rx,Num_scs)));
            rx_raw_data = h_s * serial_tx_data + h_j * jammer_signal + n;
            rx_serial_data = zeros(n_rx, Occupied_scs);
            rx_fft = rx_serial_data.';
            for i = 1:n_rx
                 rx_serial_data(i,:) = rx_raw_data(i,cp_len+1:end);
                 rx_fft(:,i) = sqrt(1/Occupied_scs)*fft(rx_serial_data(i).',N_fft);
            end
            % === Alpha estimation == %
            if ismember(s, pilot_pos)
                y = rx_fft;  % Already computed
                alpha = zeros(N_bits_per_symb,1);

                for k = 1:N_bits_per_symb
                    r1 = y(k,1) - Hs(1,k)*pilot_matrix(k);
                    r2 = y(k,2) - Hs(2,k)*pilot_matrix(k);
                    alpha(k) = r1 / r2;
                end

                % Compare with true alpha (if known)
                true_alpha = Hj(1,:) ./ Hj(2,:);
                disp([alpha(10), true_alpha(10)]);  % Example debug
            end

        end
        
    end
    
end