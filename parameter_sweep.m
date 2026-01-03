

% Parameter Stability Sweep
% Analyzes SNR recovery performance as a function of EMCCD Gain.
% Standalone simulation.

clear; clc;

%Simulation Constants
sigma_read = 14.19;
gain_vals = [50, 100, 200, 300, 400, 500];
mu_test = 2.0; 
N_trials = 1000;
adu_vec = -100:2500;

results = zeros(length(gain_vals), 1);

disp('Running gain sweep...');

for i = 1:length(gain_vals)
    g_curr = gain_vals(i);
    
    % 1. Generate Batch Data
    photons = poissrnd(mu_test, N_trials, 1);
    adu_sim = zeros(N_trials, 1);
    
    % Gain stage
    idx_valid = photons > 0;
    if any(idx_valid)
        adu_sim(idx_valid) = gamrnd(photons(idx_valid), g_curr);
    end
    % Add noise
    adu_sim = adu_sim + normrnd(0, sigma_read, N_trials, 1);
    
    % 2. Compute Thresholds (Fast Approximation)
    % Noise kernel
    k_pdf = normpdf(-100:100, 0, sigma_read);
    k_pdf = k_pdf / sum(k_pdf);
    
    % Generate signal templates
    L = zeros(length(adu_vec), 3);
    for k = 1:2
        p_ideal = gampdf(adu_vec, k, g_curr);
        p_ideal(adu_vec < 0) = 0;
        % Convolve
        p_conv = conv(p_ideal, k_pdf, 'same');
        L(:, k) = (p_conv / sum(p_conv)).';
    end
    
    % Bayesian inversion
    prior = poisspdf(0:2, mu_test);
    p_noise = normpdf(adu_vec, 0, sigma_read);
    
    post_0 = (p_noise * prior(1)).';
    post_1 = L(:, 1) * prior(2);
    post_2 = L(:, 2) * prior(3);
    
    % Threshold search
    start = find(adu_vec >= 0, 1);
    
    idx_t1 = find(post_1(start:end) > post_0(start:end), 1) + start - 1;
    if isempty(idx_t1), idx_t1 = start; end
    T1 = adu_vec(idx_t1);
    
    idx_t2 = find(post_2(start:end) > post_1(start:end), 1) + start - 1;
    if isempty(idx_t2), idx_t2 = length(adu_vec); end
    T2 = adu_vec(idx_t2);
    
    % 3. Evaluate Recovery
    count_bin = sum(adu_sim > 3 * sigma_read);
    count_res = sum(adu_sim > T1) + sum(adu_sim > T2);
    
    if count_bin > 0
        results(i) = count_res / count_bin;
    else
        results(i) = 1;
    end
end

figure; 
plot(gain_vals, results, 'k-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
grid on;
xlabel('Gain'); ylabel('Recovery Factor');
title('Algorithm Robustness vs Gain');
