data = sig;

ECG = data(1, :)';
ECG_size = size(ECG);
Fs = 125;
Ti = 0;
Td = 8;
Th = 0.35;

s = Fs * Ti + 1;
e = s + Fs * Td;
X = s:e;
Y = ECG(s:e);
LEN = size(Y)
figure('Name', 'Original ECG'), plot(X, Y);

% remove DC Component
h = fft(Y);
h(1) = 0;

Y_filter = ifft(h);
figure('Name', 'High Pass Filtered ECG'), plot(X, Y_filter);

% Find range
H = max(Y_filter);
L = min(Y_filter);
D = (H - L) / 2;

% Rescale
Y_scaled = Y_filter ./ D;
figure('Name', 'Scaled ECG'), plot(X, Y_scaled);

Y_sq = Y_scaled .^ 2;
figure('Name', 'Squared ECG'), plot(X, Y_sq);

Y_peak = Y_scaled;
Y_peak(Y_peak <= Th) = 0;
Y_peak(Y_peak > Th) = 1;
figure('Name', 'Final ECG'), plot(X, Y_peak);

beat_count = 0;
differ = 0;
prev = 0;
delay = 0;

for i = 1:LEN(1)
    if Y_peak(i) >= 0.9
        if  delay <= 0.1
            delay = 10;
            beat_count = beat_count + 1;
            if prev ~= 0
                differ = differ + i - prev;
            end
            prev = i;
        else
            delay = delay - 1;
        end
    end
    if delay > 0
        delay = delay - 1;
    end
end

beat_count = beat_count - 1
differ
beat = beat_count / ((differ / Fs) / 60)
