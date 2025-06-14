clear all;
clc
jam_power_values = 10^12*[0,10,20,30,40,50,60,70,80,0]; 
OFDM_symbols = 14;
N_packets = 500;
mod_order = 2;
occupied_subcarriers = 48;
N_subcarriers = 64;
cp_len = 16;
n_trials = 10;
pdr_results = zeros(1,n_trials);
pilot_rows = [1,3,6,9,11];
pilot_matrix = zeros(1,occupied_subcarriers);
pilot_matrix(occupied_subcarriers/2 - 4 : occupied_subcarriers/2 + 8) = 1;
noise_power = 0.001;
%Hs,Hj,t,j,noise, alpha -- normalization
for run = 1:n_trials
    Packet_success=0;
    for packets = 1: N_packets
        success=0;
        data_bits = randi([0 1], OFDM_symbols, occupied_subcarriers);
        for i = pilot_rows
            data_bits(i,:) = pilot_matrix;
        end

        %Channel Coeffs -- Jammer coeffs not known to us
        
        hs = (randn(2,1) + 1i*randn(2,1)) / sqrt(2);    % ------ sender coeff
        Hs = sqrt(1/N_subcarriers)*[fft(hs(1),N_subcarriers); fft(hs(2),N_subcarriers)];  % ------ Freq domain
        hj = (randn(2,1) + 1i*randn(2,1)) / sqrt(2);    % ------ jammer coeff
        Hj = sqrt(1/N_subcarriers)*[fft(hj(1),N_subcarriers); fft(hj(2),N_subcarriers)];  % ------ Freq domain
        
        for symbol = 1:OFDM_symbols

            current_symbol = data_bits(symbol,:);
            
            %Jammer config
            j = jammer(N_subcarriers,jam_power_values(run));
    
            %Transmitter config
            t = transmitter(occupied_subcarriers, mod_order,cp_len,current_symbol);
    
            %Receiver config
            y = receiver(hs,hj,t,j,N_subcarriers,occupied_subcarriers,cp_len,noise_power);
    
            %Jammer coeff ratio
            if ismember(symbol,pilot_rows)
                pilot_signal = pskmod(pilot_matrix.',mod_order).';
                alpha = Jammer_coeff_ratio_estimation(Hs(:,cp_len+1:end),pilot_signal,y);
                mean(alpha)
            end
            rx_data = Interference_cancellation(y,Hs,alpha,cp_len,occupied_subcarriers, N_subcarriers);
            rx_bits = pskdemod(rx_data, mod_order);
    
            if all(rx_bits == data_bits(symbol,:))
                success = success + 1;
            end
        end
        if success == OFDM_symbols
            Packet_success = Packet_success + 1;
        end
    end
    pdr = Packet_success / N_packets;
    pdr_results(run) = pdr;
    fprintf("Run %d: PDR = %.2f%%\n", run, pdr * 100);
end
fprintf("Average PDR across %d runs: %.2f%%\n", n_trials, mean(pdr_results)*100);

% === Plotting ===
figure;
plot(jam_power_values, pdr_results* 100,'-o','LineWidth',2);
grid on;
xlabel('Jamming Power');
ylabel('Packet Delivery Rate (PDR) [%]');
title('PDR vs. Jamming Power');
xlim([5000000000000 500000000000000]);
ylim([0 105])

%Interference Cancellation ----------------------------
function rx_data = Interference_cancellation(Y,Hs,alpha,cp_len,occupied_subcarriers,N_subcarriers)
 %INTERFERENCE_CANCELLATION Projects the received signal onto a different subspace
 %and obtains the projected received signal 

 rx_dec_data = (Y(1,:) - alpha.*Y(2,:))./(Hs(1,:) - alpha.*Hs(2,:));
 rx_no_cp = rx_dec_data(cp_len+1:end);
 rx_data = rx_no_cp;
 % rx_data = fft(rx_no_cp, occupied_subcarriers);
end

%Jammer -----------------------------------------------
function j = jammer(N_subcarriers,jam_power)
%JAMMER random noise generation
j = jam_power*(randn(1,N_subcarriers) + 1i * randn(1,N_subcarriers));
end

%Jammer coeff ratio estimation ------------------------
function alpha = Jammer_coeff_ratio_estimation(Hs,pilot,y)
%JAMMER_COEFF_ESTIMATION Estimates jammer coeff ratio.
    jam_signal = y - [Hs(1,:).*pilot;Hs(2,:).*pilot];
    alpha = jam_signal(1, :) ./ jam_signal(2, :); 
end

%Receiver ---------------------------------------------
function Y = receiver(hs,hj,Txs,Txj,N_subcarriers,occupied_subcarriers,cp_len,noise_power)
%RECEIVER Receiver antennas modelling
    
    noise = sqrt(noise_power)*(randn(2, N_subcarriers) + 1i*randn(2,N_subcarriers));
    Y_cp = [hs(1)*Txs + hj(1)*Txj ; hs(2)*Txs + hj(2)*Txj];
    Y_cp = Y_cp + noise;
    Y = [Y_cp(1,cp_len+1:end);Y_cp(2,cp_len+1:end)];
    Y = sqrt(1/occupied_subcarriers)*[fft(Y(1,:).',occupied_subcarriers).'; fft(Y(2,:).',occupied_subcarriers).'];
end

%Transmitter ------------------------------------------
function tx_ofdm = transmitter(occupied_subcarriers,mod_order,cp_len,symbol)
%TRANSMITTER Prepares Data Transmission by implementing BPSK modulation
% BPSK: 1 bit per symbol
    tx_power = 1;
    mod_data = sqrt(tx_power)*pskmod(symbol, mod_order);            % BPSK modulation
    time_data = sqrt(occupied_subcarriers)*ifft(mod_data,occupied_subcarriers);
    tx_ofdm = [time_data(end - cp_len + 1 : end),time_data];
end