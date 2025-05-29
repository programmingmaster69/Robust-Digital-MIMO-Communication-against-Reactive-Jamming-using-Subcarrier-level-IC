function j = jammer(N_subcarriers,cp_len,jam_power)
%JAMMER random noise generation
j = sqrt(jam_power/2)*(randn(N_subcarriers+cp_len,1) + 1i * randn(N_subcarriers+cp_len,1));
end

