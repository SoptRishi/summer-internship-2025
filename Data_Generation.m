% EMCCD Sensor Simulation
% Simulates photon arrival, electron multiplication, and readout noise.
% Based on standard probabilistic models for EMCCD detectors.

clear; clc;

% -- System Configuration --
Gain = 300;            % Mean gain (G)
ReadNoise = 14.19;     % Readout noise sigma
Prob_CIC = 0.0477;     % Clock Induced Charge probability
N_frames = 1000;       % Total frames
img_h = 100;           % Sensor height
img_w = 100;           % Sensor width

% -- Beam Profile Generation --
[X, Y] = meshgrid(1:img_w, 1:img_h);
mu_center = 2.0;       % Peak intensity (photons/pixel)
beam_width = 15;       % Spatial sigma
% Gaussian intensity distribution I(x,y)
Intensity_Map = mu_center * exp(-((X - img_w/2).^2 + (Y - img_h/2).^2) / (2 * beam_width^2));

% -- Acquisition Loop --
Raw_Stack = zeros(img_h, img_w, N_frames);

disp('Starting acquisition simulation...');

for f = 1:N_frames
    % 1. Photon Arrival (Poissonian shot noise)
    photons = poissrnd(Intensity_Map);
    
    % 2. Spurious Charge (CIC)
    % Modeled as Bernoulli process added to input electrons
    cic_events = rand(img_h, img_w) < Prob_CIC;
    electrons_in = photons + cic_events;
    
    % 3. Multiplication Register (Stochastic Gain)
    % Output follows Gamma(n, G) for n > 0 input electrons
    electrons_out = zeros(img_h, img_w);
    
    mask_signal = electrons_in > 0;
    if any(mask_signal(:))
        % Sample from Gamma distribution for valid pixels
        electrons_out(mask_signal) = gamrnd(electrons_in(mask_signal), Gain);
    end
    
    % 4. Readout Stage (Gaussian thermal noise)
    noise_floor = normrnd(0, ReadNoise, img_h, img_w);
    
    % Final Digital Output (ADU)
    Raw_Stack(:, :, f) = electrons_out + noise_floor;
end

disp('Data generation complete. Variable: Raw_Stack');
