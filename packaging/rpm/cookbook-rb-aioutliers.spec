Name:     cookbook-rb-aioutliers
Version:  %{__version}
Release:  %{__release}%{?dist}
BuildArch: noarch
Summary: rbaioutliers cookbook to install and configure it in redborder environments


License:  GNU AGPLv3
URL:  https://github.com/redBorder/cookbook-rb-aioutliers
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-aioutliers
mkdir -p %{buildroot}/usr/lib64/rb-aioutliers

cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-aioutliers/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-aioutliers
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-aioutliers/README.md

%pre
if [ -d /var/chef/cookbooks/rb-aioutliers ]; then
    rm -rf /var/chef/cookbooks/rb-aioutliers
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rbaioutliers'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/rb-aioutliers ]; then
  rm -rf /var/chef/cookbooks/rb-aioutliers
fi

systemctl daemon-reload
%files
%attr(0755,root,root)
/var/chef/cookbooks/rb-aioutliers
%defattr(0644,root,root)
/var/chef/cookbooks/rb-aioutliers/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Thu Sep 26 2023 - Miguel Álvarez <malvarez@redborder.com>
- Delete rb-aioutliers dependency

* Thu Sep 26 2023 - Miguel Álvarez <malvarez@redborder.com>
- Update requirements of the cookbook

* Mon Sep 25 2023 - Miguel Álvarez <malvarez@redborder.com>
- Initial spec version
