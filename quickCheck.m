figure;
for ii = 1:16
    subplot(4, 4, ii);
    plot(data_artrem(:, ii));
    title(num2str(ii));
end

figure;
for ii = 1:16
    subplot(4, 4, ii);
    hold on
    for jj = 1:200
        loc = data_artrem((onsets_samps(jj)-100):(onsets_samps(jj)+200), ii);
        loc = loc - loc(1);
        plot(loc)
    end
    title(num2str(ii));
end
