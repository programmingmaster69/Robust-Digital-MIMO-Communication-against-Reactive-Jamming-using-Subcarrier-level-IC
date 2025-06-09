function Y = receiver(hs,hj,Txs,Txj,N_subcarriers)
%RECEIVER Receiver antennas modelling
    Y = zeros(2,N_subcarriers);
    noise_power = 0.001;
    noise = sqrt(noise_power/2)*(randn(2, N_subcarriers) + 1i*randn(2,N_subcarriers));
    % Y(1,:) = conv(hs(1,:),Txs) + hj(1,:).*Txj + noise(1,:);
    % Y(2,:) = hs(2,:).*Txs + hj(2,:).*Txj + noise(2,:);
    for i = 1:N_subcarriers
        Y(:,i) = conv(hs,Txs(i)) + conv(hj,Txj(i)) + noise;
    end
end

