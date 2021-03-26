% Yet another junk script to compare some variables.
% In this case, load bleachEvents (1925x240x2), coldEvents, and collectSelV(1925x2) by hand.
cold = squeeze(sum(coldEvents, 2));

figure(1)
scatter(cold(:, 1), collectSelV(:, 1));
xlabel("Number of cold events");
ylabel("SelV");
title("Mounding Coral");
figure(2)
scatter(cold(:, 2), collectSelV(:, 2));
xlabel("Number of cold events");
ylabel("SelV");
title("Branching Coral");

% now we also have psw2.
% What is the range?  What min psw2 would keep SelV above 2?
fprintf("psw2 min %6.2f, median %6.2f, max %6.2f\n", min(collectpsw2),median(collectpsw2), ...
    max(collectpsw2));
make2(:, 1) = collectpsw2' * 2 ./ collectSelV(:, 1);
make2(:, 2) = collectpsw2' * 2 ./ collectSelV(:, 2);

% Argh - too much fancy indexing.
for i = 1:1925
    if collectSelV(i, 1) > 2
        make2(i, 1) = 0;
    end
    if collectSelV(i, 2) > 2
        make2(i, 2) = 0;
    end
end
idx = find(make2 > 0);

sstVar(:, 1) = collectSelV(:,1) ./ collectpsw2(1, :)' / 1.25;
sstVar(:, 2) = collectSelV(:,2) ./ collectpsw2(1, :)';
fprintf("SelV quartiles  %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(collectSelV(:, 1), [0 0.25 0.5 0.75 1.0]));
fprintf("psw2 quartiles  %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(collectpsw2(1, :), [0 0.25 0.5 0.75 1.0]));
fprintf("var(SST) mound  %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(sstVar(:, 1), [0 0.25 0.5 0.75 1.0]));
fprintf("var(SST) branch %6.3f %6.3f %6.3f %6.3f %6.3f (expect same as above)\n", quantile(sstVar(:, 2), [0 0.25 0.5 0.75 1.0]));
fprintf("var(SST) code   %6.3f %6.3f %6.3f %6.3f %6.3f \n", quantile(collectVar, [0 0.25 0.5 0.75 1.0]));
fprintf("pseudocode: SelV = [1.25 1] * psw2 * var(SST)\n");

fprintf("Values of psw2 min which could keep SelV over 2.\n");
fprintf("For all: %6.3f\n", max(max(make2(idx))));
fprintf("Quartiles %6.3f %6.3f %6.3f \n", quantile(make2(idx), [0.25 0.5 0.75]));


figure()
coldSum = squeeze(sum(sum(coldEvents,3), 2));
idx = find(coldSum == 0);
scatter(collectVar(1, idx), collectSelV(idx,1), 6, [0 0 0]);
hold on;
idx = find(coldSum == 1);
scatter(collectVar(idx), collectSelV(idx,1), 5, [0 1 0]);
idx = find(coldSum > 1 & coldSum < 5);
scatter(collectVar(idx), collectSelV(idx,1), 4, [0 1 1]);
idx = find(coldSum >= 5);
scatter(collectVar(idx), collectSelV(idx,1), 3, [1 0 0])
xlabel("SST variance");
ylabel("SelV");
legend("Black = 0", "Green = 1", "Cyan = 2-4", "Red > 4", "Location", "southeast");

figure()
scatter(collectVar, collectpsw2(:));
xlabel("SST variance");
ylabel("psw2");

figure()
scatter(collectSelV(:, 1), collectpsw2);
xlabel("SelV");
ylabel("psw2");
