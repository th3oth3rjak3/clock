Name:           Clock
Version:        0.0.1
Release:        1%{?dist}
Summary:        A simple clock

License:        The Unlicense
URL:            
Source0:        

BuildRequires:  
Requires:       

%description


%prep
%autosetup


%build
%configure
%make_build


%install
%make_install


%files
%license add-license-file-here
%doc add-docs-here



%changelog
* Thu Feb 06 2025 th3oth3rjak3 <jake.d.hathaway@gmail.com>
- Create simple clock.
