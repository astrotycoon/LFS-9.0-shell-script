#! /bin/bash

# export LC_ALL=C

# auxiliary function
info()
{
	echo -e "\033[32minfo: $1\033[0m"
}

warn()
{
	echo -e "\033[31mwarn: $1\033[0m"
}

error()
{
	echo -e "\033[31merror: $1\033[0m"
}

check_version()
{
	if [ $# -ne 2 ]; then
		error "check_version func need two arguments: "
		return
	fi

}

check_version_range()
{
	if [ $# -ne 3 ]; then
		error "check_version func need two arguments"
		return
	fi

}

if test "$(whoami)" != "root"; then
	error "You must be the root."; exit
fi

# 2.2. Host System Requirements (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#pre-hostreqs)
# (1) Bash-3.2 (/bin/sh should be a symbolic or hard link to bash)  
if [ -h /bin/sh ]; then
	if ! readlink -f /bin/sh | grep -q bash; then
		error "/bin/sh does not point to bash"; exit
	fi
	info "$(which sh) -> $(readlink -f $(which bash))"
else
	error "/bin/sh is not a symbolic link"; exit
fi

if [[ $SHELL =~ ^/.*/bash ]]; then
	# shell is bash 
	bash_version="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
	if [ $(echo "$bash_version >= 3.2" | bc) = "1" ]; then
		info "bash version $bash_version ...OK"
	else
		error "bash version is too low"; exit
	fi
else
	error "current shell is not bash"; exit
fi

# (2) Binutils-2.25 (Versions greater than 2.32 are not recommended as they have not been tested)  
if [ -x $(which ld) ]; then
	binutils_version=$(ld --version | head -n1 | grep -Eo "[0-9]+\.[0-9]+")  
	if [ $(echo "$binutils_version >= 2.25 && $binutils_version <= 2.32" | bc) = "1" ]; then
		info "Binutils version $binutils_version ...OK"
	else
		error "Binutils version does not meet the requiremetns"; exit
	fi
else
	error "binutils is not installed"; exit
fi

# (3) Bison-2.7 (/usr/bin/yacc should be a link to bison or small script that executes bison)
if [ -h $(which yacc) ]; then
	info "$(which yacc) -> $(readlink -f $(which yacc))"
	if ! readlink -f $(which yacc) | grep -q bison; then
		error "$(which yacc) does not point to bison"; exit
	fi
elif [ -x $(which yacc) ]; then
	true
	info "yacc is $($(which yacc) --version | head -n1)"
else
	error "Bison is not installed"; exit
fi

bison_version=$(yacc --version | head -n1 | grep -Eo "[0-9]+\.[0-9]+")
if [ $(echo "$bison_version >= 2.7" | bc) = "1" ]; then
	info "Bison version $bison_version ...OK"
else
	error "Bison version is too low"; exit
fi

# (4) Bzip2-1.0.4
if [ -x $(which bzip2) ]; then
	bzip2_version=$(bzip2 --version |& head -n1 | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
	info "Bzip2 version $bzip2_version ...OK"		
else
	error "Bzip2 is not installed"; exit
fi

# (5) Coreutils-6.9
if [ -x $(which ls) ]; then
	coreutils_version=$(ls --version | head -n1 | cut -d")" -f2)
	if [ $(echo "$coreutils_version >= 6.9" | bc) = "1" ]; then
		info "Coreutils version $coreutils_version ...OK"
	else
		error "Coreutils version is too low"; exit
	fi
else
	error "Coreutils is not installed"; exit
fi

# (6) Diffutils-2.8.1
if [ -x $(which diff) ]; then
	diffutils_version=$(diff --version | head -n1 | grep -Eo "[0-9]+\.[0-9]+")
	if [ $(echo "$diffutils_version >= 2.8" | bc) = "1" ]; then
		info "Diffutils version $diffutils_version ...OK"
	else
		error "Diffutils version is too low"; exit
	fi
else
	error "Diffutils is not installed"; exit
fi

# (7) Findutils-4.2.31
if [ -x $(which find) ]; then
	findutils_version=$(find --version | head -n1 | grep -Eo "[0-9]+\.[0-9]+")
	if [ $(echo "$findutils_version >= 4.2" | bc) = "1" ]; then
		info "Findutils version $findutils_version ...OK"
	else
		error "Findutils version is too low"; exit
	fi
else
	error "Findutils is not installed"; exit
fi

# (8) Gawk-4.0.1 (/usr/bin/awk should be a link to gawk) 
if [ -h $(which awk) ]; then
	info "$(which awk) -> $(readlink -f $(which awk))"
	if ! readlink -f $(which awk) | grep -q gawk; then
		error "$(which awk) does not point to gawk"
	fi	
elif [ -x $(which awk) ]; then
	true
else
	error "Gawk is not installed"; exit
fi

gawk_version=$(awk --version | head -n1 | cut -d" " -f3 | grep -Eo "[0-9]+\.[0-9]+")
if [ $(bc <<< "$gawk_version >= 4.0") = "1" ]; then
	info "Gawk version $gawk_version ...OK"
else
	error "Gawk version is too low"; exit
fi

# (9) GCC-6.2 including the C++ compiler, g++ (Versions greater than 9.2.0 are not recommended as they have not been tested)
if [ -x $(which gcc) ] && [ -x $(which g++) ]; then
	gcc_version=$(gcc --version | head -n1 | cut -d')' -f2 | cut -d'.' -f-2)
	if [ $(bc <<< "$gcc_version >= 6.2 && $gcc_version < 9.2") = "1" ]; then
		info "GCC version $gcc_version ...OK"
	else
		error "GCC version is too low"; exit
	fi
else
	error "GCC is not installed"; exit
fi

# (10) Glibc-2.11 (Versions greater than 2.30 are not recommended as they have not been tested)
glibc_version=$(ldd --version | head -n1 | cut -d")" -f2)
if [ $(bc <<< "$glibc_version >= 2.11 && $glibc_version < 2.30") = "1" ]; then
	info "glibc version $glibc_version ...OK"
else
	error "glibc version does not meet the requiremetns"; exit
fi

# (11) Grep-2.5.1a
if [ -x $(which grep) ]; then
	grep_version=$(grep --version | head -n1 | cut -d")" -f2)
	if [ $(bc <<< "$grep_version >= 2.5") = "1" ]; then
		info "Grep version $grep_version ...OK"
	else
		error "Grep version is too low"; exit
	fi
else
	error "Grep is not installed"; exit
fi

# (12) Gzip-1.3.12
if [ -x $(which gzip) ]; then
	gzip_version=$(gzip --version | head -n1 | cut -d" " -f2)
	if [ $(bc <<< "$gzip_version >= 1.3") = "1" ]; then
		info "Gzip version $gzip_version ...OK"
	else
		error "Gzip version is too low"; exit
	fi
else
	error "Gzip is not installed"; exit
fi

# (13) Linux Kernel-3.2
kernel_version=$(uname -r | cut -d"." -f-2)
if [ $(bc <<< "$kernel_version >= 3.2") = "1" ]; then
	info "Linux Kernel version $kernel_version ...OK"
else
	error "Linux Kernel is too low"; exit
fi

# (14) M4-1.4.10
if [ -x $(which m4) ]; then
	m4_version=$(m4 --version | head -n1 | cut -d")" -f2 | cut -d"." -f-2)
	if [ $(bc <<< "$m4_version >= 1.4") = "1" ]; then
		info "M4 version $m4_version ...OK"
	else
		error "M4 version is too low"; exit
	fi
else
	error "M4 is not installed"; exit
fi

# (15) Make-4.0
if [ -x $(which make) ]; then
	make_version=$(make --version | head -n1 | cut -d" " -f3)
	if [ $(bc <<< "$make_version >= 4.0") = "1" ]; then
		info "Make version $make_version ...OK"
	else
		error "Make version is too low"; exit
	fi
else
	error "Make is not installed"; exit
fi

# (16) Patch-2.5.4
if [ -x $(which patch) ]; then
	patch_version=$(patch --version | head -n1 | cut -d" " -f3 | cut -d"." -f-2)
	if [ $(bc <<< "$patch_version >= 2.5") = "1" ]; then
		info "Patch version $patch_version ...OK"
	else
		error "Patch version is too low"; exit
	fi
else
	error "Patch is not installed"; exit
fi

# (17) Perl-5.8.8 
if [ -x $(which perl) ]; then
	perl_version=$(perl "-V:version" | cut -d"=" -f2 | cut -d"'" -f2 | cut -d"." -f2)
	if [ $(bc <<< "$perl_version >= 5.8") = "1" ]; then
		info "Perl version $perl_version ...OK"
	else
		error "Perl version is too low"; exit
	fi
else
	error "Perl is not installed"; exit
fi

# (18) Python-3.4

if [ -x $(which python3) ]; then
	python3_version=$(python3 --version | cut -d" " -f2 | cut -d"." -f-2)
	if [ $(bc <<< "$python3_version >= 3.4") = "1" ]; then
		info "Python3 version $python3_version ...OK"
	else
		error "Python3 version is too low"; exit
	fi
else
	error "Python3 is not installed"; exit
fi

# (19)Sed-4.1.5
if [ -x $(which sed) ]; then
	sed_version=$(sed --version | head -n1 | cut -d" " -f4)
	if [ $(bc <<< "$sed_version >= 4.1") = "1" ]; then
		info "Sed version $sed_version ...OK"
	else
		error "Sed version is too low"; exit
	fi
else
	error "Sed is not installed"; exit
fi

# (20) Tar-1.22
if [ -x $(which tar) ]; then
	tar_version=$(tar --version | head -n1 | cut -d" " -f4)
	if [ $(bc <<< "$tar_version >= 1.22") = "1" ]; then
		info "Tar version $tar_version ...OK"
	else
		error "Tar version is too low"; exit
	fi
else
	error "Tar is not installed"; exit
fi

# (21) Texinfo-4.7
if [ -x $(which makeinfo) ]; then
	texinfo_version=$(makeinfo --version | head -n1 | cut -d" " -f4)
	if [ $(bc <<< "$texinfo_version >= 4.7") = "1" ]; then
		info "Texinfo version $texinfo_version ...OK"
	else
		error "Texinfo version is too low"; exit
	fi
else
	error "Texinfo is not installed"; exit
fi

# (22) Xz-5.0.0
if [ -x $(which xz) ]; then
	xz_version=$(xz --version | head -n1 | cut -d")" -f2 | cut -d"." -f-2)
	if [ $(bc <<< "$xz_version >= 5.0") = "1" ]; then
		info "Xz version $xz_version ...OK"
	else
		error "Xz version is too low"; exit
	fi
else
	error "Xz is not installed"; exit
fi

info "==============================> Host System Requirements ...OK"



if [ -e lfs.img ]; then
	rm -rf lfs.img
fi

if dd if=/dev/zero of=lfs.img bs=1G count=64 status=progress; then
	info "==============================> Create lfs.img ...OK"
else
	error "Create lfs.img ...failed"; exit
fi

# 2.5. Creating a File System on the Partition (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#space-creatingfilesystem)
if fdisk lfs.img <<< "n
p


+2G
n
p



w
" >/dev/null 2>&1; then
	fdisk -l lfs.img
	info "==============================> Creating a New Partition ...OK"
else
	error "==============================> Creating a New Partition ...failed"; exit
fi


loop_device=$(losetup --find --show lfs.img)
if read partion1 partion2 <<< "$(kpartx -av $loop_device | cut -d" " -f3 | tr "\n" " ")"; then

	info "partion1 = $partion1, partion2 = $partion2"

	swap_partion_map=/dev/mapper/$partion1
	root_partion_map=/dev/mapper/$partion2

	if mkswap $swap_partion_map &>/dev/null; then
		info "mkswap ...OK"
	else
		error "mkswap ...failed"; exit
	fi

	if mkfs.ext4 $root_partion_map &>/dev/null; then
		info "mkfs.ext4 ...OK"
	else
		error "mkfs.ext4 ...failed"; exit
	fi	
else
	error "kpartx device map ...failed"; exit
fi

# kpartx -d $loop_device
# losetup --detach $loop_device
info "==============================> Creating File System on Partition ...OK"

# 2.6. Setting The $LFS Variable (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#ch-partitioning-aboutlfs)
export LFS=/mnt/lfs

# 2.7. Mounting the New Partition (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#space-mounting)
mkdir -p $LFS
if mount -t ext4 $root_partion_map $LFS; then
	info "mount $root_partion_map ...OK"
else
	error "mount $root_partion_map ...failed"; exit
fi

# 3.1. Introduction (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#materials-introduction)
mkdir -p $LFS/sources # the place to store the tarballs and patches and as a working directory
chmod a+wt $LFS/sources # Make this directory writable and sticky

if cp -rfd 9.0/* $LFS/sources; then # 9.0 is the package directory
	info "copy package & patchs ...OK"
else
	error "copy package & patchs ...failed"; exit
fi

pushd $LFS/sources
if md5sum -c md5sums --quiet; then
	info "md5sum ...OK"
else
	error "md5sum ...failed"; exit
fi
popd

# 4.2. Creating the $LFS/tools Directory (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#ch-tools-creatingtoolsdir)
mkdir -p $LFS/tools
ln -sf $LFS/tools /

# 4.3. Adding the LFS User (https://lfs-hk.koddos.net/lfs/downloads/9.0/LFS-BOOK-9.0-NOCHUNKS.html#ch-tools-addinguser)
if grep -q lfs /etc/passwd; then
	userdel --force lfs #　--force also del group
fi
groupadd lfs
if [ -d /home/lfs ]; then
	rm -rf /home/lfs
fi
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

chown lfs:lfs $LFS/tools
chown lfs:lfs $LFS/sources
chown lfs:lfs /tools

sudo -u lfs -i env -i $(which bash) << 'EOF'
# 4.4. Setting Up the Environment 
set +h
umask 022
export LFS=/mnt/lfs
export LC_ALL=C
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=/tools/bin:/bin/:/usr/bin

info()
{
	echo -e "\033[32minfo: $1\033[0m"
}

warn()
{
	echo -e "\033[31mwarn: $1\033[0m"
}

error()
{
	echo -e "\033[31merror: $1\033[0m"
}

pushd $LFS/sources
# 5.4. Binutils-2.32 - Pass 1 
if tar xf binutils-2.32.tar.xz; then
	info "Extract binutils-2.32.tar.xz ...OK"
	pushd binutils-2.32
	mkdir -p build && cd build
	if ../configure --prefix=/tools       	\
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror; then
		info "Binutils configure ...OK"
	else
		error "Binutils configure ...failed"
	fi
	if make; then
		info "Binutils make ...OK"
	else
		error "Binutils make ...failed"
	fi
	case $(uname -m) in
  		x86_64) mkdir -p /tools/lib && ln -sv lib /tools/lib64 ;;
	esac
	make install	
	popd

else
	error "Extract binutils-2.32.tar.xz ...failed"
fi 

# 
popd

EOF

# su - lfs << 'EOF'
# # 4.4. Setting Up the Environment 
# exec env -i HOME=$HOME TERM=$TERM $(which bash) << EOL
# umask
# set +h
# umask 022
# export LFS=/mnt/lfs
# export LC_ALL=C
# export LFS_TGT=$(uname -m)-lfs-linux-gnu
# export PATH=/tools/bin:/bin/:/usr/bin
# set > /tmp/lfs
# umask
# EOL
# EOF

sleep 3000
userdel --force lfs
unlink /tools
umount $LFS
kpartx -d $loop_device
losetup --detach $loop_device
rm -rf lfs.img
