function []=savepdf(h, filename_w_extension)

if nargin==1
  filename_w_extension = h;
  h = gcf;
end

pos = get(h, 'position');
set(h,'PaperPositionMode','Auto','PaperUnits','points','PaperSize',[pos(3), pos(4)]);
print(h,filename_w_extension,'-dpdf','-r0');
