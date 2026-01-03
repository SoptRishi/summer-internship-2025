
% ODMR Sensitivity Simulation (High Flux Regime)
% Simulates NV center magnetometry to demonstrate dynamic range recovery.

clear; clc;

% Exp Parameters
Sigma_N = 14.19; 
Gain_EM = 300;
Frames_Integration = 2000; 
Freq_Steps = 21;

% NV Physics
Mu_Baseline = 4.5;    % Saturation regime
Contrast = 0.20;      % 20% dip depth
Dip_Center = 11; 
Dip_Width = 3;

%Threshold Pre-calculation 
disp('Calibrating high-flux thresholds...');
axis_x = -100:3000;
kernel = normpdf(-100:100, 0, Sigma_N);
kernel = kernel / sum(kernel);

% Generate Likelihoods (up to 5 photons)
L_templates = zeros(length(axis_x), 6);
for k = 1:5
    pdf_g = gampdf(axis_x, k, Gain_EM);
    pdf_g(axis_x < 0) = 0;
    conv_res = conv(pdf_g, kernel, 'same');
    L_templates(:, k) = (conv_res / sum(conv_res)).';
end

% Bayes Inversion
priors = poisspdf(0:5, Mu_Baseline);
pdf_n = normpdf(axis_x, 0, Sigma_N);
post_0 = (pdf_n * priors(1)).';

post_k = zeros(length(axis_x), 5);
for k = 1:5
    post_k(:, k) = L_templates(:, k) * priors(k+1);
end

% Determine Ts
Ts = zeros(1, 4);
search_start = find(axis_x >= 0, 1);

% T1
idx = find(post_k(search_start:end, 1) > post_0(search_start:end), 1) + search_start - 1;
if isempty(idx), idx = search_start; end
Ts(1) = axis_x(idx);

% T2..T4
for k = 2:4
    idx = find(post_k(search_start:end, k) > post_k(search_start:end, k-1), 1) + search_start - 1;
    if isempty(idx), idx = length(axis_x); end
    Ts(k) = axis_x(idx);
end

% Sweep Simulation
sig_bin = zeros(Freq_Steps, 1);
sig_res = zeros(Freq_Steps, 1);

disp('Sweeping frequencies...');

for f = 1:Freq_Steps
    % Lorentzian profile
    delta = f - Dip_Center;
    shape = 1 / (1 + (delta / Dip_Width).^2);
    mu_curr = Mu_Baseline * (1 - Contrast * shape);
    
    % Generate burst
    k_in = poissrnd(mu_curr, Frames_Integration, 1);
    x_out = zeros(Frames_Integration, 1);
    
    valid = k_in > 0;
    if any(valid), x_out(valid) = gamrnd(k_in(valid), Gain_EM); end
    x_out = x_out + normrnd(0, Sigma_N, Frames_Integration, 1);
    
    % Processing
    % 1. Binary (Clips > 1)
    sig_bin(f) = sum(x_out > 3 * Sigma_N);
    
    % 2. Resolved (Sum of thresholds passed)
    counts = (x_out > Ts(1)) + (x_out > Ts(2)) + (x_out > Ts(3)) + (x_out > Ts(4));
    sig_res(f) = sum(counts);
end

%Plotting
% Normalize
norm_b = mean(sig_bin(1:3));
norm_r = mean(sig_res(1:3));
y_bin = sig_bin / norm_b;
y_res = sig_res / norm_r;

figure; hold on;
plot(1:Freq_Steps, y_bin, 'b.--', 'MarkerSize', 12);
plot(1:Freq_Steps, y_res, 'r.-', 'MarkerSize', 12, 'LineWidth', 1.5);
grid on;
legend('Standard', 'Resolved');
title('ODMR Contrast Recovery');
ylabel('Normalized PL');

gain_factor = (1 - min(y_res)) / (1 - min(y_bin));
fprintf('Sensitivity Gain: %.2fx\n', gain_factor);
