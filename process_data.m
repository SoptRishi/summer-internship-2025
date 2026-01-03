

% Data Processing & SNR Analysis
% Applies calibrated thresholds to resolve photon numbers and compares 
% contrast against standard binary thresholding.

%Config 
sigma_mult = 3; %3-sigma

[h, w, frames] = size(Raw_Stack);
Resolved_Stack = zeros(h, w, frames, 'uint8');

% Photon Tagging 
disp('Resolving photon numbers...');
T1 = Thresh_Map(:, :, 1);
T2 = Thresh_Map(:, :, 2);
T3 = Thresh_Map(:, :, 3);
T4 = Thresh_Map(:, :, 4);

% comparison
for f = 1:frames
    frame_raw = Raw_Stack(:, :, f);
    % Cumulative thresholding
    counts = (frame_raw > T1) + (frame_raw > T2) + (frame_raw > T3) + (frame_raw > T4);
    Resolved_Stack(:, :, f) = uint8(counts);
end

%Performance Metrics
% 1. Standard Binary Method
thresh_binary = sigma_mult * ReadNoise;
Stack_Binary = Raw_Stack > thresh_binary;

Img_Binary = sum(Stack_Binary, 3);
Img_Resolved = sum(Resolved_Stack, 3);

% 2. Region Definition (Signal vs Background)
[XX, YY] = meshgrid(1:w, 1:h);
dist_from_center = sqrt((XX - w/2).^2 + (YY - h/2).^2);

mask_sig = dist_from_center <= 5;           % Center spot
mask_bg  = dist_from_center > (w/2 - 5);    % Corners

% 3. SNR Calculation
% Method A: Binary
sig_bin = mean(Img_Binary(mask_sig));
bg_bin  = mean(Img_Binary(mask_bg));
noise_bin = std(double(Img_Binary(mask_bg)));
snr_bin = (sig_bin - bg_bin) / noise_bin;

% Method B: Resolved
sig_res = mean(Img_Resolved(mask_sig));
bg_res  = mean(Img_Resolved(mask_bg));
noise_res = std(double(Img_Resolved(mask_bg)));
snr_res = (sig_res - bg_res) / noise_res;

% Output 
fprintf('Results\n');
fprintf('SNR (Binary):   %.2f\n', snr_bin);
fprintf('SNR (Resolved): %.2f\n', snr_res);
fprintf('Improvement:    %.2fx\n', snr_res / snr_bin);
