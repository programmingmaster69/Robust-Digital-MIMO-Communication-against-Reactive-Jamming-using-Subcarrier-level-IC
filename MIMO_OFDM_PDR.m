clear all;
clc
jam_power_values = [10,50,100,150,200,250,300,350,400,450]; 
OFDM_symbols = 14;
N_packets = 500;
mod_order = 2;
occupied_subcarriers = 48;
N_subcarriers = 64;
cp_len = 16;
n_trials = 10;
pdr_results = zeros(1,n_trials);
pilot_rows = [1,6,11];
alpha = zeros(1,N_subcarriers);
%Hs estimation -- done
%Iterative Tracking -- done
%Jammer length change -- pending

jammer_sender_switch = false ; %Determines whether to evaluate jammer or sender coeffs.
sender_coeff_switch = false;   %Determines which sender coeff to evaluate.
for run = 1:n_trials
    Packet_success=0;
    for packets = 1: N_packets
        success=0;
        data_bits = randi([0 1], OFDM_symbols, occupied_subcarriers);
        for i = pilot_rows
            data_bits(i,:) = ones(1,occupied_subcarriers);
        end
        hs_est = zeros(2,N_subcarriers);
        for symbol = 1:OFDM_symbols

            current_symbol = data_bits(symbol,:);

            %Channel Coeffs -- Jammer coeffs not known to us
            hs = (randn(2,N_subcarriers) + 1i*randn(2,N_subcarriers)) / sqrt(2); % ------ sender coeff
            hj = (randn(2,N_subcarriers) + 1i*randn(2,N_subcarriers)) / sqrt(2); % ------ jammer coeff
            
            %Jammer config
            j = jammer(N_subcarriers,jam_power_values(run));
    
            %Transmitter config
            t = transmitter(occupied_subcarriers, mod_order,cp_len,current_symbol);
    
            %Receiver config
            y = receiver(hs,hj,t,j,N_subcarriers);
    
            %Jammer and sender coeff ratio
            if ismember(symbol,pilot_rows) && jammer_sender_switch == 0
                hs_est = sender_coeff_estimator(symbol, t, alpha, y,sender_coeff_switch, hs_est);
                sender_coeff_switch = ~sender_coeff_switch; 
                jammer_sender_switch = ~jammer_sender_switch;
            elseif ismember(symbol,pilot_rows) && jammer_sender_switch == 1
                alpha = Jammer_coeff_ratio_estimation(hs_est,t,y);
                jammer_sender_switch = ~jammer_sender_switch;
            end
            rx_data = Interference_cancellation(y,hs_est,alpha,cp_len,occupied_subcarriers);
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
semilogx(jam_power_values, pdr_results* 100,'-o','LineWidth',2);
grid on;
xlabel('Jamming Power');
ylabel('Packet Delivery Rate (PDR) [%]');
title('PDR vs. Jamming Power');
xlim([5000000000000 500000000000000]);
ylim([0 105])