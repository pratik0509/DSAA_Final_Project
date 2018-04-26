
load './DATA_01_TYPE01.mat';
load 'DATA_01_TYPE01_BPMtrace.mat';
data = sig;

I = data(2:end, :)';
I_sz = size(I);
Fs = 125;
fmin = 1.0;
fmax = 2.5;
tmax = floor(I_sz(1) / 125);
delt = 8;
step = 2;
s = 0:2:(tmax - delt);
s = (s * Fs) + 1;
dist = delt * Fs;
dilation = 64 * Fs * 16;

accx = I(:, 3);
accy = I(:, 4);
accz = I(:, 5);
acc = accx.^2 + accy.^2 + accz.^2;
acc = acc;

% LMSF = dsp.LMSFilter(5, 'Method', 'Normalized LMS', 'Length', 5);
% [ylms, eppg1, wlms] = LMSF(acc, I(:, 1));
% I(:, 1) = eppg1;
% L = 31;
% bw = firwiener(L-1,acc,I(:, 1)); % Optimal FIR Wiener filter
% yw = filter(bw,1,acc);           % Estimate of x using Wiener filter
% eppg1 = I(:, 1) - yw;            % Estimate of actual sinusoid
% I(:, 1) = eppg1;

I(:, 1) = filter_noise(I(:, 1), acc);

% [ylms, eppg2, wlms] = LMSF(acc, I(:, 2));
% I(:, 2) = eppg2;

I(:, 2) = filter_noise(I(:, 2), acc);

Y1 = [];
Y2 = [];

for i = s
    PPG1 = I(i:(i + dist), 1);
    PPG2 = I(i:(i + dist), 2);
    PPG1 = padarray(PPG1, dilation - dist, 'post');
    PPG2 = padarray(PPG2, dilation - dist, 'post');
    FFTPPG1 = fft(PPG1);
    FFTPPG2 = fft(PPG2);
    
    first = fmin * dilation / Fs;
    last = fmax * dilation / Fs;
    
    
    temp = FFTPPG1(first:last, :);
    temp = abs(temp);
    [~, peak_ppg1] = max(temp);
    peak_ppg1 = peak_ppg1 + first;
    
    temp = FFTPPG2(first:last, :);
    temp = abs(temp);
    [~, peak_ppg2] = max(temp);
    peak_ppg2 = peak_ppg2 + first;
    
    fppg1 = peak_ppg1 * Fs / dilation;
    fppg2 = peak_ppg2 * Fs / dilation;
    
    HR1 = fppg1 * 60;
    HR2 = fppg2 * 60;
    Y1 = [Y1; HR1];
    Y2 = [Y2; HR2];
    Yavg = (Y1 + Y2) / 2;
end

err_hr1 = Y1 - BPM0;
err_hr1 = err_hr1 .^ 2;
sum(err_hr1)

err_hr2 = Y2 - BPM0;
err_hr2 = err_hr2 .^ 2;
sum(err_hr2)

err_hravg = Yavg - BPM0;
err_hravg = err_hravg .^ 2;
sum(err_hravg)


function [Y] = filter_noise(I, N)
    % LMSF = dsp.LMSFilter(5, 'Method', 'Normalized LMS', 'Length', 5);
    % [ylms, eppg1, wlms] = LMSF(acc, I(:, 1));
    % I(:, 1) = eppg1;
    L = 32;
    bw = firwiener(L-1,N,I); % Optimal FIR Wiener filter
    yw = filter(bw,1,N);           % Estimate of x using Wiener filter
    Y = I - yw;            % Estimate of actual sinusoid
end