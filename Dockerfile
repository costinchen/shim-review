FROM tencentos/tencentos_server33
COPY shim-unsigned-x64-15.8-1.tl3.src.rpm /
# build efi
RUN yum -y install wget rpm-build gcc gcc-c++ make yum-utils
RUN rpm -ivh shim-unsigned-x64-15.8-1.tl3.src.rpm
RUN yum-builddep -y /root/rpmbuild/SPECS/shim-unsigned-x64.spec
RUN sed -i 's/linux32 -B/linux32/g' /root/rpmbuild/SPECS/shim-unsigned-x64.spec
RUN rpmbuild -bb /root/rpmbuild/SPECS/shim-unsigned-x64.spec
# compare
COPY shimx64.efi /
RUN rpm2cpio /root/rpmbuild/RPMS/x86_64/shim-unsigned-x64-15.8-1.tl3.x86_64.rpm | cpio -diu
RUN ls -l /*.efi ./usr/share/shim/15.8-1.tl3/*/shim*.efi
RUN hexdump -Cv ./usr/share/shim/15.8-1.tl3/x64/shimx64.efi > built-x64.hex
RUN hexdump -Cv /shimx64.efi > orig-x64.hex
RUN objdump -h /usr/share/shim/15.8-1.tl3/x64/shimx64.efi
RUN diff -u orig-x64.hex built-x64.hex
RUN pesign -h -P -i /usr/share/shim/15.8-1.tl3/x64/shimx64.efi
RUN pesign -h -P -i /shimx64.efi
RUN sha256sum /usr/share/shim/15.8-1.tl3/x64/shimx64.efi /shimx64.efi
