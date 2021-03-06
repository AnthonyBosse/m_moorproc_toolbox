function bool = nc_isvar ( ncfile, varname )
% NC_ISVAR:  determines if a variable is present in a netCDF file
%
% BOOL = NC_ISVAR(NCFILE,VARNAME) returns true if the variable VARNAME is 
% present in the netCDF file NCFILE.  Otherwise false is returned.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: nc_isvar.m 2528 2008-11-03 23:06:25Z johnevans007 $
% $LastChangedDate: 2008-11-03 18:06:25 -0500 (Mon, 03 Nov 2008) $
% $LastChangedRevision: 2528 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nargchk(2,2,nargin);
nargoutchk(1,1,nargout);

%
% Both inputs must be character
if nargin ~= 2
	error ( 'SNCTOOLS:NC_ISVAR:badInput', 'must have two inputs' );
end
if ~ischar(ncfile)
	error ( 'SNCTOOLS:NC_ISVAR:badInput', 'first argument must be character.' );
end
if ~ischar(varname)
	error ( 'SNCTOOLS:NC_ISVAR:badInput', 'second argument must be character.' );
end



%
% Do we use java instead of mexnc?
if getpref('SNCTOOLS','USE_TMW',false);
	bool = nc_isvar_tmw ( ncfile, varname );
elseif getpref ( 'SNCTOOLS', 'USE_JAVA', false );
	bool = nc_isvar_java ( ncfile, varname );
else
	bool = nc_isvar_mexnc ( ncfile, varname );
end

return








%-----------------------------------------------------------------------
function bool = nc_isvar_tmw ( ncfile, varname )

ncid = netcdf.open(ncfile, nc_nowrite_mode );
try
	varid = netcdf.inqVarID(ncid,varname);
	bool = true;
catch myException
	bool = false;
end

netcdf.close(ncid);
return









%-----------------------------------------------------------------------
function bool = nc_isvar_mexnc ( ncfile, varname )

[ncid,status] = mexnc('open',ncfile, nc_nowrite_mode );
if status ~= 0
	ncerr = mexnc ( 'STRERROR', status );
	error ( 'SNCTOOLS:NC_ISVAR:MEXNC:OPEN', ncerr );
end


[varid,status] = mexnc('INQ_VARID',ncid,varname);
if ( status ~= 0 )
	bool = false;
elseif varid >= 0
	bool = true;
else
	error ( 'SNCTOOLS:NC_ISVAR:unknownResult', ...
	        'Unknown result, INQ_VARID succeeded, but returned a negative varid.  That should not happen.' );
end

mexnc('close',ncid);
return









function bool = nc_isvar_java ( ncfile, varname )
% assume false until we know otherwise
bool = false;

import ucar.nc2.dods.*     % import opendap reader classes
import ucar.nc2.*          % have to import this (NetcdfFile) as well for local reads
                           % Now that's just brilliant.  


%
% Try it as a local file.  If not a local file, try as
% via HTTP, then as dods
if exist(ncfile,'file')
	jncid = NetcdfFile.open(ncfile);
else
	try 
		jncid = NetcdfFile.open ( ncfile )
	catch
		try
			jncid = DODSNetcdfFile(ncfile);
		catch
			msg = sprintf ( 'Could not open ''%s'' as either a local file, a regular URL, or as a DODS URL.' );
			error ( 'SNCTOOLS:nc_varget_java:fileOpenFailure', msg );
		end
	end
end




jvarid = jncid.findVariable(varname);

%
% Did we find anything?
if ~isempty(jvarid)
	bool = true;
end

close(jncid);

return

