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
form = ([0 30 90 150 210 270 300] .* Fs) + 1;

accx = I(:, 3);
accy = I(:, 4);
accz = I(:, 5);
acc = accx.^2 + accy.^2 + accz.^2;
acc = acc.^0.5;

figure, plot(I(:, 1));

%I(:, 1) = filter_noise(I(:, 1), acc);
%I(:, 2) = filter_noise(I(:, 2), acc);


figure, plot(I(:, 1));


Y1 = [];
Y2 = [];

for i = s
    PPG1 = I(i:(i + dist), 1);
    PPG2 = I(i:(i + dist), 2);
    PPG1 = filter_noise(PPG1, acc(i:(i + dist)));
    PPG2 = filter_noise(PPG2, acc(i:(i + dist)));
    PPG1 = padarray(PPG1, dilation - dist, 'post');
    PPG2 = padarray(PPG2, dilation - dist, 'post');
    FFTPPG1 = fft(PPG1);
    FFTPPG2 = fft(PPG2);
    
    first = fmin * dilation / Fs;
    last = fmax * dilation / Fs;
    
    temp = FFTPPG1(first:last, :);
    temp = abs(temp);
    [~, peak_ppg1] = max(temp);
    peak_ppg1 = peak_ppg1 + first - 1;
    
    temp = FFTPPG2(first:last, :);
    temp = abs(temp);
    [~, peak_ppg2] = max(temp);
    peak_ppg2 = peak_ppg2 + first - 1;
    delta = 21;
    if i ~= 1
        peak_ppg1 = find_peak(temp, first, Y1(end), Fs, dilation, delta);
        peak_ppg2 = find_peak(temp, first, Y2(end), Fs, dilation, delta);
    end

    fppg1 = peak_ppg1 * Fs / dilation;
    fppg2 = peak_ppg2 * Fs / dilation;

    HR1 = fppg1 * 60;
    HR2 = fppg2 * 60;
    Y1 = [Y1; HR1];
    Y2 = [Y2; HR2];
end

L = 9;
Yavg = (Y1 + Y2) / 2;
Y1 = medfilt1(Y1, L);
Y2 = medfilt1(Y2, L);

T = (Y1 + Y2) / 2;
T = medfilt1(T, L);
Yavg(L: end - L) = T(L:end - L);
gfil = gausswin(3)';
gfil = gfil / sum(gfil);
T = filter(gfil, 1, Yavg);
Yavg(3:end) = T(3:end);

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
%    LMSF = dsp.LMSFilter(7, 'Method', 'Normalized LMS');
%    [ylms, eppg1, wlms] = LMSF(N, I);
%    Y = eppg1;
    L = 3;
    bw = firwiener(L-1,N,I);
    yw = filter(bw,1,N);
    Y = I - yw;
end

function [ind] = find_peak(I, offset, base, Fs, dilation, delta)
    flag = true;
    while flag
        [~, loc] = max(I);
        ind = loc + offset - 1;
        hr = ind * Fs / dilation * 60;
        if abs(hr - base) <= delta
            flag = false;
        else
            I(loc) = 0;
        end
    end
end