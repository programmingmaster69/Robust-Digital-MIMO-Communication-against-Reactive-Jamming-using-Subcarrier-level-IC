function Y = receiver(hs,hj,Txs,Txj,N_subcarriers)
%RECEIVER Receiver antennas modelling
    noise_power = 0.01;
    noise = sqrt(noise_power/2)*randn(2, N_subcarriers);
    Y= hs*Txs + hj*Txj + noise;
end

