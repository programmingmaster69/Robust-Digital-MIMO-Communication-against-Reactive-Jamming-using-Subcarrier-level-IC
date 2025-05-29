function Y = receiver(hs,hj,Txs,Txj)
%RECEIVER Receiver antennas modelling
    Rx1 = hs(1)*Txs + hj(1)*Txj;
    Rx2 = hs(2)*Txs + hj(2)*Txj;
    Y = [Rx1, Rx2].';
end

