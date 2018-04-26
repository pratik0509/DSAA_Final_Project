load './DATA_07_TYPE02.mat';
load 'DATA_07_TYPE02_BPMtrace.mat';
data = sig;

I = data(2:end, :)';
I_sz = size(I);
Fs = 125;
fmin = 1.2;
fmax = 2.5;
tmax = floor(I_sz(1) / Fs);
flag = 0;
if rem(I_sz(1), Fs) == 0
    flag = 1;
end
delt = 8;
step = 2;
s = 0:2:(tmax - delt);
s = (s * Fs) + 1;
s(end) = s(end) - flag;
dist = delt * Fs;
dilation = 64 * Fs * 16;
form = ([0 30 90 150 210 270 300] .* Fs) + 1;

accx = I(:, 3) .^ 2;
accy = I(:, 4) .^ 2;
accz = I(:, 5) .^ 2;
acc = accx + accy + accz;
% acc = acc;

%I(:, 1) = I(:, 1);
%I(:, 2) = I(:, 2);

I(:, 1) = filter_noise(I(:, 1), accx);
I(:, 2) = filter_noise(I(:, 2), accx);

I(:, 1) = filter_noise(I(:, 1), accy);
I(:, 2) = filter_noise(I(:, 2), accy);

I(:, 1) = filter_noise(I(:, 1), accz);
I(:, 2) = filter_noise(I(:, 2), accz);

filter_delt = 30;
filter_step = 10;
st = 0:filter_step:(tmax - filter_delt);
st = st * Fs + 1;
filter_dist = filter_delt * Fs;
for i = st
    ind = i:i+filter_dist;
    I(ind, 1) = filter_noise(I(ind, 1), accx(ind));
    I(ind, 2) = filter_noise(I(ind, 2), accx(ind));
    
    I(ind, 1) = filter_noise(I(ind, 1), accy(ind));
    I(ind, 2) = filter_noise(I(ind, 2), accy(ind));
    
    I(ind, 1) = filter_noise(I(ind, 1), accz(ind));
    I(ind, 2) = filter_noise(I(ind, 2), accz(ind));

end

%I(:, 1) = I(:, 1);
%I(:, 2) = I(:, 2);

Y1 = [];
Y2 = [];

for i = s
    PPG1 = I(i:(i + dist), 1);
    PPG2 = I(i:(i + dist), 2);
%    PPG1 = filter_noise(PPG1, acc(i:(i + dist)), M);
%    PPG2 = filter_noise(PPG2, acc(i:(i + dist)), M);
    PPG1 = padarray(PPG1, dilation - dist, 'post');
    PPG2 = padarray(PPG2, dilation - dist, 'post');
    FFTPPG1 = fft(PPG1);
    FFTPPG2 = fft(PPG2);
    
    first = ceil(fmin * dilation / Fs);
    last = ceil(fmax * dilation / Fs);
    
    temp = FFTPPG1(first:last, :);
    temp = abs(temp);
    [~, peak_ppg1] = max(temp);
    peak_ppg1 = peak_ppg1 + first - 1;
    
    temp = FFTPPG2(first:last, :);
    temp = abs(temp);
    [~, peak_ppg2] = max(temp);
    peak_ppg2 = peak_ppg2 + first - 1;

    fppg1 = peak_ppg1 * Fs / dilation;
    fppg2 = peak_ppg2 * Fs / dilation;

    HR1 = fppg1 * 60;
    HR2 = fppg2 * 60;
    Y1 = [Y1; HR1];
    Y2 = [Y2; HR2];
end

L = 9;
Yavg = max(Y1, Y2);
%Y1 = medfilt1(Y1, L);
%Y2 = medfilt1(Y2, L);

T = Yavg;
T = medfilt1(T, L);
Yavg(L: end - L) = T(L:end - L);
%gfil = gausswin(L)';
%gfil = gfil / sum(gfil);
%T = filter(gfil, 1, Yavg);
%Yavg(L:end-L) = T(L:end-L);

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
%    L = 3;
%    bw = firwiener(L-1,N,Y);
%    yw = filter(bw,1,N);
%    Y = Y - yw;
    M      = 10;
    delta  = 0.01;
    P0     = (1/delta)*eye(M,M);
    rlsfilt = dsp.RLSFilter(M,'InitialInverseCovariance',P0);
    [y e] = rlsfilt(N, I);
    Y = e;
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