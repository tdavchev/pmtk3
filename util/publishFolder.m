function publishFolder(folder)
% Publish a single demos directory, (called by publishDemos).
%
% Example
%
% publishFolder bayesDemos

doNotEvalList = {'PMTKinteractive', 'PMTKbroken'};
globalEval    = true;
googleRoot    = sprintf('http://code.google.com/p/pmtk3/source/browse/trunk/demos/%s/', folder);
dest = fullfile(pmtk3Root(), 'docs', 'demos');
demos = processExamples({}, {}, 0, false, folder);

info = createStruct({'name', 'description', 'doEval', 'localLink', 'googleLink'});
cd(dest);
for i=1:numel(demos)
    info(i) = mfileInfo(demos{i});
    %publishFile(demos{i}, fullfile(dest, folder), info(i).doEval);
end

perm = sortidx(cellfuncell(@(str)lower(str),{info.name}));
sortedInfo = info(perm);
fid = setupHTMLfile(fullfile(folder, 'index.html'), folder);
setupTable(fid, {'Demo', 'Brief Description',},[20, 60]);
lprintf = @(link, name)fprintf(fid, '\t<td> <a href="%s"> %s </td>\n', link, name);
for i=1:numel(sortedInfo) 
    fprintf(fid,'<tr bgcolor="white" align="left">\n');
    lprintf(sortedInfo(i).googleLink, sortedInfo(i).name);
    lprintf(sortedInfo(i).localLink, sortedInfo(i).description);
    fprintf(fid,'</tr>\n');
end
fprintf(fid,'</table>');
closeHTMLfile(fid);

    function info = mfileInfo(mfile)
        info.name = mfile(1:end-2);
        h = help(mfile);
        if isempty(h)
            info.description = '&nbsp;';
        else
            h = tokenize(h, '\n');
            info.description = h{1};
        end
        info.doEval = globalEval && isempty(intersect(tagfinder(mfile), doNotEvalList));
        info.localLink = [info.name, '.html'];
        info.googleLink = [googleRoot, mfile];
    end
end




function publishFile(mfile, outputDir, evalCode)
% Publish an m-file to the specified output directory.
options.evalCode = evalCode;
options.outputDir = outputDir;
options.format = 'html';
options.createThumbnail = false;
publish(mfile, options);
evalin('base','clear all');
close all hidden;
end


function fid = setupHTMLfile(fname, folder)
% Setup a root HTML file
d = date;
fid = fopen(fname,'w+');
fprintf(fid,'<html>\n');
fprintf(fid,'<head>\n');
fprintf(fid,'<font align="left" style="color:#990000"><h2>PMTK3: %s</h2></font>\n', folder);
fprintf(fid,'<br>Revision Date: %s<br>\n',d);
fprintf(fid,'<br>Auto-generated by publishDemos.m<br>\n');
fprintf(fid,'</head>\n');
fprintf(fid,'<body>\n\n');
fprintf(fid,'<br>\n');
end

function closeHTMLfile(fid)
% Close a root HTML file
fprintf(fid,'\n</body>\n');
fprintf(fid,'</html>\n');
fclose(fid);
end

function setupTable(fid,names,widths)
% Setup an HTML table with the specified field names and widths in percentages
fprintf(fid,'<table width="100%%" border="3" cellpadding="5" cellspacing="2" >\n');
fprintf(fid,'<tr bgcolor="#990000" align="center">\n');
for i=1:numel(names)
    fprintf(fid,'\t<th width="%d%%">%s</th>\n', widths(i), names{i});
end
fprintf(fid,'</tr>\n');
end

