function Y = receiver(hs,hj,Txs,Txj)
%RECEIVER Receiver antennas modelling
    Y= hs*Txs + hj*Txj;
end

