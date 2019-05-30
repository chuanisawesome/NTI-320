Name:					            # Package name needs to be unique
Version: 	                # Want to increase to be up-to-date
Release:			            # Release needs to be up-to-date for patches, tweeks and such.
Summary: 	                # What the package is does

Group:				            # Who made it
License:	                # Who can use it
URL:		                  # How to find the group that made it
Source0:	                # How to find the source

BuildRequires:            # The dependency relationships between packages
Requires:	                # Additional packages the client must have installed to run the program

%description
                          # Description of the package that will be shown when using the command man

%prep					            # Build environment for the software is created
					                # for the environment, file prep, and so forth

%setup  			            # Used to unpack your source code
					                # by default, it will grab source from your source url
					


%build				            # This builds from source (performing the build)

%configure		            # You can add additional configure flags here 

make %{?_smp_mflags}			# Make arguments here (recall nrpe is make all instead of simply make)


%install
rm -rf %{buildroot}			  # Clean out the build dir				

make install DESTDIR=%{buildroot}	# Puts compiled code in rpmbuild 'build' dir

%clean
rm -rf %{buildroot}			  # Clean up after building the package


#------After installation with %post. Scripts can be run prior to an uninstall with %postun.----#

%post                     # Postscript runs after installation


%postun                   # Runs when RPM package is uninstalled


%files					          # Additional files required by the package installed

%defattr(-,root,root)			# Sets default perms


%config                   # Our example wrapper script for our package

%doc					            # Cocs for the package that goes into man section


%changelog				        # changes you (and others) have made and why
