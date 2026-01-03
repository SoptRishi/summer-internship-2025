
% Bayesian Threshold Calculation
% Computes optimal discrimination thresholds for photon number resolution
% using a pixel-wise Maximum Likelihood Estimate (MLE) approach.

% Uses variables from previous step if available, else defaults
if ~exist('Intensity_Map', 'var')
    error('Please run generation script first.');
end

mu_range = [min(Intensity_Map(:)), max(Intensity_Map(:))];
mu_steps = linspace(mu_range(1), mu_range(2), 50);
k_max = 4; % Max photon number to resolve

% Define domain for PDF integration
adu_axis = -200:1:2500; 

% Probability Density Functions (Likelihoods)
fprintf('Computing likelihood templates...\n');
L_matrix = zeros(length(adu_axis), k_max + 2);

% 0-Photon PDF (Pure Noise)
kernel_x = -100:100;
pdf_noise = normpdf(kernel_x, 0, ReadNoise);
pdf_noise = pdf_noise / sum(pdf_noise); % Normalize kernel

% Compute P(x|k) for k = 0 to k_max
% Convolve ideal Gamma response with Gaussian readout noise
L_matrix(:, 1) = normpdf(adu_axis, 0, ReadNoise); % k=0

for k = 1:k_max+1
    % Ideal gain response (Gamma)
    pdf_gain = gampdf(adu_axis, k, Gain);
    pdf_gain(adu_axis < 0) = 0; % Physics constraint
    
    % Sensor response (Convolution)
    pdf_sensor = conv(pdf_gain, pdf_noise, 'same');
    L_matrix(:, k+1) = pdf_sensor / sum(pdf_sensor);
end

% Lookup Table Generation
fprintf('Generating threshold map...\n');
lut_thresholds = zeros(length(mu_steps), k_max);
wb = waitbar(0, 'Inverting probabilities...');

for i = 1:length(mu_steps)
    mu_local = mu_steps(i);
    
    % Priors P(k)
    priors = poisspdf(0:k_max+1, mu_local);
    
    % Posteriors P(k|x) ~ P(x|k) * P(k)
    posteriors = zeros(size(L_matrix));
    for k_idx = 1:length(priors)
        posteriors(:, k_idx) = L_matrix(:, k_idx) * priors(k_idx);
    end
    
    % Normalize evidence
    evidence = sum(posteriors, 2);
    posteriors = posteriors ./ evidence;
    posteriors(isnan(posteriors)) = 0;
    
    % Determine decision boundaries (Intersections)
    for k = 1:k_max
        p_lower = posteriors(:, k);     % P(k-1|x)
        p_upper = posteriors(:, k+1);   % P(k|x)
        
        % Find first crossover point after zero
        start_idx = find(adu_axis > 0, 1);
        cross_rel = find(p_upper(start_idx:end) > p_lower(start_idx:end), 1);
        
        if ~isempty(cross_rel)
            lut_thresholds(i, k) = adu_axis(start_idx + cross_rel - 1);
        else
            lut_thresholds(i, k) = NaN;
        end
    end
    waitbar(i/length(mu_steps), wb);
end
close(wb);

% Spatial Map Interpolation 
% Map LUT values to full sensor grid based on intensity map
Thresh_Map = zeros(img_h, img_w, k_max);

fprintf('Interpolating spatial map...\n');
for k = 1:k_max
    Thresh_Map(:, :, k) = interp1(mu_steps, lut_thresholds(:, k), Intensity_Map, 'linear', 'extrap');
end

disp('Calibration complete. Variable: Thresh_Map');
