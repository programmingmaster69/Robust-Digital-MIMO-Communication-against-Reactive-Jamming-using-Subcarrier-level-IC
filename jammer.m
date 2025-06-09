function j = jammer(N_subcarriers,jam_power)
%JAMMER random noise generation
j = sqrt(jam_power/2)*(randn(1,N_subcarriers) + 1i * randn(1,N_subcarriers));
end

