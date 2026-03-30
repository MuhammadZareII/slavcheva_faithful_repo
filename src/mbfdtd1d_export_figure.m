function mbfdtd1d_export_figure(fig, out_base, dpi)
%MBFDTD1D_EXPORT_FIGURE Export vector + raster copies of a figure.

if nargin < 3
    dpi = 300;
end

[out_dir,~,~] = fileparts(out_base);
if ~isempty(out_dir) && ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

exportgraphics(fig, [out_base '.pdf'], 'ContentType', 'vector');
exportgraphics(fig, [out_base '.png'], 'Resolution', dpi);
end
