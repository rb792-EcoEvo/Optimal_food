clear; clc;

crop = 'wheat';

load(['data/crop_maps/' crop '.mat'],'harvested_area','production');

land = ~isnan(production);
production(isnan(production)) = -10;
production(production > 2.5e4) = 2.5e4;

figure(1); clf;
c = parula(1e3); colormap([[1 1 1];c])
hold on;
imagesc(production);
contour(land,'-k');
title("Global wheat production");
ax = gca;
 colorbar;
ax.YDir = 'reverse';
set(gca,'xtick',[]); set(gca,'ytick',[]);
