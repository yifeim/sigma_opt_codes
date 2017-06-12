function [] = cat10lns(filename, nblines)

default nblines=10;

if isstr(nblines)
  nblines = str2num(nblines);
end

if ~strcmpi(filename(end-1:end),'.m')
  filename = [filename, '.m'];
end

fid=fopen(filename,  'r');
if fid<=0
  warning(['file ', filename, ' not exist!']);
  return;
end

for i=1:nblines
  if ~feof(fid);
    disp(fgetl(fid));
  end
end
disp('%-------------------------%');
  
