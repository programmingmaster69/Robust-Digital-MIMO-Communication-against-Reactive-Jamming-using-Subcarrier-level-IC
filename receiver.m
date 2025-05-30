function Y = receiver(hs,hj,Txs,Txj,N_subcarriers)
%RECEIVER Receiver antennas modelling
    noise = randn(1, N_subcarriers);
    Y= hs*Txs + hj*Txj + noise;
end

