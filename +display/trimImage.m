% uses ImageMagick to trim an image 
% so that it looks as big as possible in the final PDF


function trimImage(filename)

filename = fullfile(display.saveHere,filename);

cmd = ['/usr/local/bin/convert ' filename ' -trim ' filename];
try
	system(cmd)
catch
end