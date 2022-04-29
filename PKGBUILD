# U-Boot: Orange Pi 3
# Maintainer: Furkan Kardame  <f.kardame@manjaro.org>
# Contributor: Kevin Mihelich <kevin@archlinuxarm.org>

pkgname=uboot-opi3-lts
pkgver=2022.04
pkgrel=1
_tfaver=2.5
pkgdesc="U-Boot for OPI 3 LTS"
arch=('aarch64')
url='http://www.denx.de/wiki/U-Boot/WebHome'
license=('GPL')
makedepends=('bc' 'git' 'python-setuptools' 'swig' 'dtc')
provides=('uboot')
conflicts=('uboot')
install=${pkgname}.install
source=("ftp://ftp.denx.de/pub/u-boot/u-boot-${pkgver/rc/-rc}.tar.bz2"
        "https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git/snapshot/trusted-firmware-a-$_tfaver.tar.gz"
	"1001-add-sun50i-h6-opi3-lts.patch"
	"fix_atf_compile_issue.patch")
md5sums=('a5a70f6c723d2601da7ea93ae95642f9'
         'cd0455f0dcd4161201074bacb93446b1'
         'ebbdf37b1079ddfb279d1193569bfe1e'
         '0d38104fa5e5c598bcfca85cffa1d091')

prepare() {
  apply_patches() {
      local PATCH
      for PATCH in "${source[@]}"; do
          PATCH="${PATCH%%::*}"
          PATCH="${PATCH##*/}"
          [[ ${PATCH} = $1*.patch ]] || continue
          msg2 "Applying patch: ${PATCH}..."
          patch -N -p1 < "../${PATCH}" || true
      done
  }
#	cd "${srcdir}/trusted-firmware-a-$_tfaver"
#	patch -N -p1 -i "${srcdir}/fix_atf_compile_issue.patch"
 	
	cd u-boot-${pkgver/rc/-rc}
	apply_patches 0
	apply_patches 1
}

build() {
  # Avoid build warnings by editing a .config option in place instead of
  # appending an option to .config, if an option is already present
  update_config() {
    if ! grep -q "^$1=$2$" .config; then
      if grep -q "^# $1 is not set$" .config; then
        sed -i -e "s/^# $1 is not set$/$1=$2/g" .config
      elif grep -q "^$1=" .config; then
        sed -i -e "s/^$1=.*/$1=$2/g" .config
      else
        echo "$1=$2" >> .config
      fi
    fi
  }

  unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

  cd trusted-firmware-a-$_tfaver

  echo -e "\nBuilding TF-A for OPI 3 LTS...\n"
  make PLAT=sun50i_h6 bl31
  cp build/sun50i_h6/release/bl31.bin ../u-boot-${pkgver/rc/-rc}

  cd ../u-boot-${pkgver/rc/-rc}

  echo -e "\nBuilding U-Boot for OPI 3 LTS...\n"
  make orangepi_3_lts_defconfig 
  update_config 'CONFIG_IDENT_STRING' '" Manjaro Linux ARM"'
  update_config 'CONFIG_OF_LIBFDT_OVERLAY' 'y'
  make EXTRAVERSION=-${pkgrel}
  cp -a u-boot-sunxi-with-spl.bin u-boot-sunxi-with-spl-opi3-lts.bin
}

package() {
  cd u-boot-${pkgver/rc/-rc}

  mkdir -p "${pkgdir}/boot/extlinux"

  install -D -m 0644 u-boot-sunxi-with-spl-opi3-lts.bin -t "${pkgdir}"/boot
}
