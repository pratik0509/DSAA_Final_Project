close all;

load './DATA_01_TYPE01.mat';
load 'DATA_01_TYPE01_BPMtrace.mat';
data = sig;

I = data(2:end, :)';
size(I);
Fs = 125;
fmin = 1.0;
fmax = 2.5;
tmax = 5 * 60;
delt = 8;
step = 2;
s = 0:2:(tmax - delt + step);
s = (s * Fs) + 1;
dist = delt * Fs;
dilation = 64 * Fs * 16;

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