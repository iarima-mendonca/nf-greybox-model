function Graphics_subplots(Wperm, tmps, result_min, SR, SRbnd, flux, fluxbnd, x, y)
%% Graphical results

stored_values = load('../NF_parameter_estimation/p_values.mat');
names_memb = stored_values.names_memb;
CH = "Chosen point";
legend_name = [names_memb; CH];


SRbnd1 = SRbnd(:,:,1);
SRbnd2 = SRbnd(:,:,2);
SRbnd3 = SRbnd(:,:,3);

SR1 = SR(:,:,1);
SR2 = SR(:,:,2);
SR3 = SR(:,:,3);

%% Flux per membrane

figure(1)
subplot(2,2,1)
    plot(tmps, fluxbnd(1,:), 'o-','Color','#0072BD')
    hold on
    plot(tmps, fluxbnd(2,:), 'o-','Color','#D95319')
    p1 = plot(tmps(y), flux(x,y), 'o');
    p1.MarkerSize = 9;
    p1.MarkerEdgeColor = 'k';
    p1.MarkerFaceColor = 'k';
    legend(legend_name,'Location','northwest')
hold off
xlim([4 24])
xlabel('TMP (bar)')
ylabel('Flux (L/m^{2}.h)')

%% Salt rejection

%COD
subplot(2,2,2)
    plot(tmps, SR1(1,:)*100, 'o-','Color','#0072BD')
    hold on
    plot(tmps, SR1(2,:)*100, 'o-','Color','#D95319')
    p2 = plot(tmps(y), SRbnd1(x,y)*100, 'o');
    p2.MarkerSize = 9;
    p2.MarkerEdgeColor = 'k';
    p2.MarkerFaceColor = 'k';
hold off
xlim([4 24])
ylim([0 100])
xlabel('TMP (bar)')
ylabel('SR COD (%)')
% title('COD Rejection')

%TN
subplot(2,2,3)
    plot(tmps, SR2(1,:)*100, 'o-','Color','#0072BD')
    hold on
    plot(tmps, SR2(2,:)*100, 'o-','Color','#D95319')
    p3 = plot(tmps(y), SRbnd2(x,y)*100, 'o','HandleVisibility','off');
    p3.MarkerSize = 9;
    p3.MarkerEdgeColor = 'k';
    p3.MarkerFaceColor = 'k';
hold off
xlim([4 24])
ylim([0 100])
xlabel('TMP (bar)')
ylabel('SR TN (%)')
% title('Nitrate Rejection')

%TP
subplot(2,2,4)
    plot(tmps, SR3(1,:)*100, 'o-','Color','#0072BD')
    hold on
    plot(tmps, SR3(2,:)*100, 'o-','Color','#D95319')
    p4 = plot(tmps(y), SRbnd3(x,y)*100, 'o','HandleVisibility','off');
    p4.MarkerSize = 9;
    p4.MarkerEdgeColor = 'k';
    p4.MarkerFaceColor = 'k';
hold off
ylim([0 100])
xlabel('TMP (bar)')
xlim([4 24])
ylabel('SR TP (%)')
% title('Phosphate Rejection')

%% Normalized costs

for k = 1:length(Wperm)
    figure(2)
    if k == 1
       hold on
    end
    ax = gca;
    ax.ColorOrderIndex = k;
    plot(tmps, result_min(k,:), '--')
end
    p5 = plot(tmps(y), result_min(x,y), 'o','HandleVisibility','off');
    p5.MarkerSize = 7;
    p5.MarkerEdgeColor = 'k';
    p5.MarkerFaceColor = 'k';
    legend(names_memb,'Location','northwest')
hold off
ylim([0 1.5])
xlabel('TMP (bar)')
ytxt = char(8364);
ylabel(['Costs (' ytxt '/m^{3}influent)'])
title('Total costs')


end