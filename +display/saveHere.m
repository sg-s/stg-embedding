% specifies the location to save figures
function savehere = saveHere()

savehere = '~/Dropbox/embedding-paper/individual-figures';

if exist(savehere,'dir')
	return
else
	savehere = pwd;
end