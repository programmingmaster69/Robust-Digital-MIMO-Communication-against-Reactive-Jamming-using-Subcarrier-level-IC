function j = jammer(N_subcarriers,jam_power)
%JAMMER random noise generation
j = jam_power*(randn(1,N_subcarriers) + 1i * randn(1,N_subcarriers));
end

