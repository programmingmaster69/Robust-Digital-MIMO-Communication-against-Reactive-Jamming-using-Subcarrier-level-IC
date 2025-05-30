function Y = receiver(hs,hj,Txs,Txj,N_subcarriers,cp_len)
%RECEIVER Receiver antennas modelling
    noise = randn(1, N_subcarriers+cp_len);
    Y= hs*Txs + hj*Txj + noise;
end

