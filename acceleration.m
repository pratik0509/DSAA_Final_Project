data = sig(4:end, :);
data_size = size(data);

X = 1:data_size(2);


figure('Name', 'PPG'), plot(X, sig(2, :));

figure('Name', 'X-acc'), plot(X, data(1, :));

figure('Name', 'Y-acc'), plot(X, data(2, :));

figure('Name', 'Z-acc'), plot(X, data(3, :));